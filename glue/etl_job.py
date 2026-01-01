"""
SchemaGuard AI - Glue ETL Job
Production ETL job with schema-aware processing using DynamicFrames.
Handles schema evolution gracefully.
"""

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import col, current_timestamp, lit
import boto3
import json
from datetime import datetime

# Initialize Glue context
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'RAW_BUCKET',
    'CURATED_BUCKET',
    'CONTRACTS_BUCKET',
    'DATABASE_NAME',
    'EXECUTION_ID'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

s3_client = boto3.client('s3')

def get_current_contract():
    """Retrieve current data contract"""
    try:
        response = s3_client.list_objects_v2(
            Bucket=args['CONTRACTS_BUCKET'],
            Prefix='contract_v'
        )
        if 'Contents' not in response:
            return None
        
        latest = sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True)[0]
        contract_response = s3_client.get_object(
            Bucket=args['CONTRACTS_BUCKET'],
            Key=latest['Key']
        )
        return json.loads(contract_response['Body'].read().decode('utf-8'))
    except Exception as e:
        print(f"Error loading contract: {str(e)}")
        return None

def apply_schema_mapping(dynamic_frame, contract):
    """Apply schema mapping based on contract"""
    if not contract:
        return dynamic_frame
    
    required_fields = contract.get('required_fields', [])
    optional_fields = contract.get('optional_fields', [])
    all_fields = required_fields + optional_fields
    
    # Select only fields defined in contract
    mapping = []
    for field in all_fields:
        mapping.append((field, "string", field, "string"))
    
    if mapping:
        return ApplyMapping.apply(
            frame=dynamic_frame,
            mappings=mapping,
            transformation_ctx="apply_mapping"
        )
    
    return dynamic_frame

def validate_required_fields(dynamic_frame, contract):
    """Validate required fields are present"""
    if not contract:
        return dynamic_frame
    
    required_fields = contract.get('required_fields', [])
    df = dynamic_frame.toDF()
    
    # Filter out rows with null required fields
    for field in required_fields:
        if field in df.columns:
            df = df.filter(col(field).isNotNull())
    
    return DynamicFrame.fromDF(df, glueContext, "validated_frame")

def add_metadata(dynamic_frame, execution_id):
    """Add processing metadata"""
    df = dynamic_frame.toDF()
    
    df = df.withColumn("processing_timestamp", current_timestamp())
    df = df.withColumn("execution_id", lit(execution_id))
    df = df.withColumn("schema_version", lit("v1"))
    
    return DynamicFrame.fromDF(df, glueContext, "metadata_frame")

def main():
    """Main ETL logic"""
    try:
        print(f"Starting ETL job for execution: {args['EXECUTION_ID']}")
        
        # Load current contract
        contract = get_current_contract()
        print(f"Loaded contract version: {contract.get('version') if contract else 'None'}")
        
        # Read raw data using DynamicFrame (schema-flexible)
        raw_path = f"s3://{args['RAW_BUCKET']}/data/"
        print(f"Reading from: {raw_path}")
        
        dynamic_frame = glueContext.create_dynamic_frame.from_options(
            format_options={"multiline": False},
            connection_type="s3",
            format="json",
            connection_options={
                "paths": [raw_path],
                "recurse": True
            },
            transformation_ctx="raw_data"
        )
        
        print(f"Raw record count: {dynamic_frame.count()}")
        
        # Apply schema mapping based on contract
        mapped_frame = apply_schema_mapping(dynamic_frame, contract)
        print(f"After mapping: {mapped_frame.count()}")
        
        # Validate required fields
        validated_frame = validate_required_fields(mapped_frame, contract)
        print(f"After validation: {validated_frame.count()}")
        
        # Add metadata
        final_frame = add_metadata(validated_frame, args['EXECUTION_ID'])
        
        # Write to curated bucket (partitioned by date)
        curated_path = f"s3://{args['CURATED_BUCKET']}/data/"
        print(f"Writing to: {curated_path}")
        
        glueContext.write_dynamic_frame.from_options(
            frame=final_frame,
            connection_type="s3",
            format="parquet",
            connection_options={
                "path": curated_path,
                "partitionKeys": ["processing_timestamp"]
            },
            transformation_ctx="write_curated"
        )
        
        # Update Glue catalog
        final_frame.toDF().createOrReplaceTempView("curated_data")
        
        print(f"ETL job completed successfully")
        print(f"Final record count: {final_frame.count()}")
        
        job.commit()
        
    except Exception as e:
        print(f"ETL job failed: {str(e)}")
        raise

if __name__ == "__main__":
    main()
