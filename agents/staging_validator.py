"""
Staging Validator Agent
Validates ETL execution in staging environment before production.
Performs data quality checks and schema validation.
"""

import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any, List

s3_client = boto3.client('s3')
athena_client = boto3.client('athena')
glue_client = boto3.client('glue')

STAGING_BUCKET = os.environ['STAGING_BUCKET']
ATHENA_OUTPUT_BUCKET = os.environ['ATHENA_OUTPUT_BUCKET']
GLUE_DATABASE = os.environ['GLUE_DATABASE']

def lambda_handler(event, context):
    """Validate staging data"""
    try:
        execution_id = event['execution_id']
        staging_path = event.get('staging_path', f's3://{STAGING_BUCKET}/data/')
        
        print(f"Validating staging for execution: {execution_id}")
        
        # Run validation checks
        validation_results = {
            'execution_id': execution_id,
            'row_count_check': validate_row_count(staging_path),
            'null_check': validate_required_fields(staging_path),
            'schema_check': validate_schema_consistency(staging_path),
            'data_quality_check': validate_data_quality(staging_path),
            'athena_query_check': validate_athena_queries(staging_path)
        }
        
        # Determine overall status
        all_passed = all(
            check.get('passed', False) 
            for check in validation_results.values() 
            if isinstance(check, dict)
        )
        
        validation_results['overall_status'] = 'PASSED' if all_passed else 'FAILED'
        validation_results['timestamp'] = datetime.utcnow().isoformat()
        
        return validation_results
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'execution_id': event.get('execution_id'),
            'overall_status': 'ERROR',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }

def validate_row_count(path: str) -> Dict:
    """Validate row count is reasonable"""
    try:
        # List objects in staging
        bucket = path.replace('s3://', '').split('/')[0]
        prefix = '/'.join(path.replace('s3://', '').split('/')[1:])
        
        response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)
        file_count = len(response.get('Contents', []))
        
        passed = file_count > 0
        return {
            'passed': passed,
            'file_count': file_count,
            'message': f'Found {file_count} files' if passed else 'No files found'
        }
    except Exception as e:
        return {'passed': False, 'error': str(e)}

def validate_required_fields(path: str) -> Dict:
    """Check required fields are not null"""
    try:
        query = f"""
        SELECT 
            COUNT(*) as total_rows,
            COUNT(id) as id_count,
            COUNT(timestamp) as timestamp_count,
            COUNT(event_type) as event_type_count
        FROM staging_table
        """
        
        result = execute_athena_query(query)
        
        if result:
            row = result[0]
            total = row.get('total_rows', 0)
            passed = (
                row.get('id_count') == total and
                row.get('timestamp_count') == total and
                row.get('event_type_count') == total
            )
            return {
                'passed': passed,
                'total_rows': total,
                'message': 'All required fields present' if passed else 'Missing required fields'
            }
        
        return {'passed': False, 'message': 'Could not execute query'}
    except Exception as e:
        return {'passed': False, 'error': str(e)}

def validate_schema_consistency(path: str) -> Dict:
    """Validate schema is consistent"""
    try:
        # Get Glue table schema
        response = glue_client.get_table(
            DatabaseName=GLUE_DATABASE,
            Name='staging_table'
        )
        
        columns = response['Table']['StorageDescriptor']['Columns']
        
        return {
            'passed': len(columns) > 0,
            'column_count': len(columns),
            'message': f'Schema has {len(columns)} columns'
        }
    except Exception as e:
        return {'passed': False, 'error': str(e)}

def validate_data_quality(path: str) -> Dict:
    """Run data quality checks"""
    try:
        query = """
        SELECT 
            COUNT(DISTINCT id) as unique_ids,
            COUNT(*) as total_rows,
            MIN(timestamp) as min_timestamp,
            MAX(timestamp) as max_timestamp
        FROM staging_table
        """
        
        result = execute_athena_query(query)
        
        if result:
            row = result[0]
            unique_ids = row.get('unique_ids', 0)
            total_rows = row.get('total_rows', 0)
            
            # Check for duplicates
            passed = unique_ids == total_rows
            
            return {
                'passed': passed,
                'unique_ids': unique_ids,
                'total_rows': total_rows,
                'message': 'No duplicates' if passed else f'Found {total_rows - unique_ids} duplicates'
            }
        
        return {'passed': False, 'message': 'Could not execute query'}
    except Exception as e:
        return {'passed': False, 'error': str(e)}

def validate_athena_queries(path: str) -> Dict:
    """Test common Athena queries"""
    try:
        test_queries = [
            "SELECT COUNT(*) FROM staging_table",
            "SELECT event_type, COUNT(*) FROM staging_table GROUP BY event_type"
        ]
        
        results = []
        for query in test_queries:
            result = execute_athena_query(query)
            results.append(result is not None)
        
        passed = all(results)
        return {
            'passed': passed,
            'queries_tested': len(test_queries),
            'queries_passed': sum(results),
            'message': 'All queries passed' if passed else 'Some queries failed'
        }
    except Exception as e:
        return {'passed': False, 'error': str(e)}

def execute_athena_query(query: str) -> List[Dict]:
    """Execute Athena query and return results"""
    try:
        response = athena_client.start_query_execution(
            QueryString=query,
            QueryExecutionContext={'Database': GLUE_DATABASE},
            ResultConfiguration={
                'OutputLocation': f's3://{ATHENA_OUTPUT_BUCKET}/query-results/'
            }
        )
        
        query_execution_id = response['QueryExecutionId']
        
        # Wait for query to complete (simplified)
        import time
        for _ in range(30):
            status = athena_client.get_query_execution(
                QueryExecutionId=query_execution_id
            )
            state = status['QueryExecution']['Status']['State']
            
            if state == 'SUCCEEDED':
                results = athena_client.get_query_results(
                    QueryExecutionId=query_execution_id
                )
                return parse_athena_results(results)
            elif state in ['FAILED', 'CANCELLED']:
                return None
            
            time.sleep(1)
        
        return None
    except Exception as e:
        print(f"Athena query error: {str(e)}")
        return None

def parse_athena_results(results: Dict) -> List[Dict]:
    """Parse Athena results into list of dicts"""
    rows = results['ResultSet']['Rows']
    if len(rows) < 2:
        return []
    
    headers = [col['VarCharValue'] for col in rows[0]['Data']]
    data = []
    
    for row in rows[1:]:
        row_data = {}
        for i, col in enumerate(row['Data']):
            row_data[headers[i]] = col.get('VarCharValue')
        data.append(row_data)
    
    return data
