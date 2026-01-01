"""
Schema Analyzer Agent
Detects schema drift by comparing incoming data schema with expected schema.
Uses Amazon Bedrock for intelligent impact analysis.
"""

import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any
import hashlib

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
bedrock_runtime = boto3.client('bedrock-runtime')

SCHEMA_HISTORY_TABLE = os.environ['SCHEMA_HISTORY_TABLE']
AGENT_MEMORY_TABLE = os.environ['AGENT_MEMORY_TABLE']
CONTRACTS_BUCKET = os.environ['CONTRACTS_BUCKET']
BEDROCK_MODEL_ID = os.environ['BEDROCK_MODEL_ID']

def lambda_handler(event, context):
    """Main handler for schema analysis"""
    try:
        execution_id = event['execution_id']
        s3_bucket = event['s3_bucket']
        s3_key = event['s3_key']
        
        print(f"Analyzing schema for execution: {execution_id}")
        
        # Extract incoming schema
        incoming_schema = extract_schema_from_s3(s3_bucket, s3_key)
        
        # Get current contract
        current_contract = get_current_contract()
        expected_schema = current_contract.get('schema', {})
        
        # Compare schemas
        schema_diff = compare_schemas(expected_schema, incoming_schema)
        
        # Classify change
        change_type = classify_change(schema_diff)
        
        # Analyze impact with Bedrock
        impact_analysis = analyze_impact_with_bedrock(schema_diff, change_type, execution_id)
        
        # Store history
        store_schema_history(execution_id, incoming_schema, expected_schema, schema_diff, change_type, impact_analysis)
        
        # Check agent memory
        auto_approve = check_agent_memory(schema_diff, change_type)
        
        return {
            'execution_id': execution_id,
            'change_type': change_type,
            'schema_diff': schema_diff,
            'incoming_schema': incoming_schema,
            'current_contract': current_contract,
            'impact_analysis': impact_analysis,
            'auto_approve': auto_approve,
            'timestamp': datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        raise

def extract_schema_from_s3(bucket: str, key: str) -> Dict[str, Any]:
    """Extract schema from JSON file"""
    response = s3_client.get_object(Bucket=bucket, Key=key)
    data = json.loads(response['Body'].read().decode('utf-8'))
    return infer_schema(data)

def infer_schema(data: Any, path: str = "") -> Dict[str, Any]:
    """Recursively infer schema from JSON data"""
    if isinstance(data, dict):
        return {
            "type": "object",
            "properties": {k: infer_schema(v, f"{path}.{k}") for k, v in data.items()}
        }
    elif isinstance(data, list):
        return {"type": "array", "items": infer_schema(data[0], f"{path}[]") if data else {}}
    elif isinstance(data, str):
        return {"type": "string"}
    elif isinstance(data, bool):
        return {"type": "boolean"}
    elif isinstance(data, int):
        return {"type": "integer"}
    elif isinstance(data, float):
        return {"type": "number"}
    elif data is None:
        return {"type": "null"}
    return {"type": "unknown"}

def get_current_contract() -> Dict[str, Any]:
    """Retrieve current contract from S3"""
    try:
        response = s3_client.list_objects_v2(Bucket=CONTRACTS_BUCKET, Prefix='contract_v')
        if 'Contents' not in response:
            return {"version": 0, "schema": {}}
        
        latest = sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True)[0]
        contract_response = s3_client.get_object(Bucket=CONTRACTS_BUCKET, Key=latest['Key'])
        return json.loads(contract_response['Body'].read().decode('utf-8'))
    except:
        return {"version": 0, "schema": {}}

def compare_schemas(expected: Dict, incoming: Dict) -> Dict[str, Any]:
    """Compare schemas and identify differences"""
    diff = {"added_fields": [], "removed_fields": [], "type_changes": []}
    
    expected_props = expected.get('properties', {})
    incoming_props = incoming.get('properties', {})
    
    for field in incoming_props:
        if field not in expected_props:
            diff["added_fields"].append({"field": field, "type": incoming_props[field].get('type')})
    
    for field in expected_props:
        if field not in incoming_props:
            diff["removed_fields"].append({"field": field, "type": expected_props[field].get('type')})
    
    for field in expected_props:
        if field in incoming_props:
            if expected_props[field].get('type') != incoming_props[field].get('type'):
                diff["type_changes"].append({
                    "field": field,
                    "expected_type": expected_props[field].get('type'),
                    "incoming_type": incoming_props[field].get('type')
                })
    
    return diff

def classify_change(schema_diff: Dict[str, Any]) -> str:
    """Classify the type of schema change"""
    if not any(schema_diff.values()):
        return "NO_CHANGE"
    if schema_diff['removed_fields'] or schema_diff['type_changes']:
        return "BREAKING"
    if schema_diff['added_fields']:
        return "ADDITIVE"
    return "UNKNOWN"

def analyze_impact_with_bedrock(schema_diff: Dict, change_type: str, execution_id: str) -> Dict:
    """Use Bedrock for impact analysis"""
    try:
        prompt = f"""Analyze schema change impact:
Change Type: {change_type}
Added: {json.dumps(schema_diff['added_fields'])}
Removed: {json.dumps(schema_diff['removed_fields'])}
Type Changes: {json.dumps(schema_diff['type_changes'])}

Provide JSON: {{"risk_level": "LOW/MEDIUM/HIGH", "impacts": [], "recommendations": [], "safe_to_auto_approve": true/false}}"""

        response = bedrock_runtime.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 1000,
                "messages": [{"role": "user", "content": prompt}]
            })
        )
        
        result = json.loads(response['body'].read())
        return json.loads(result['content'][0]['text'])
    except:
        return {"risk_level": "MEDIUM", "impacts": [], "recommendations": [], "safe_to_auto_approve": False}

def store_schema_history(execution_id, incoming_schema, expected_schema, schema_diff, change_type, impact_analysis):
    """Store in DynamoDB"""
    table = dynamodb.Table(SCHEMA_HISTORY_TABLE)
    schema_id = hashlib.md5(json.dumps(incoming_schema, sort_keys=True).encode()).hexdigest()
    timestamp = int(datetime.utcnow().timestamp() * 1000)
    
    table.put_item(Item={
        'schema_id': schema_id,
        'timestamp': timestamp,
        'execution_id': execution_id,
        'data_source': 'raw_data',
        'incoming_schema': json.dumps(incoming_schema),
        'expected_schema': json.dumps(expected_schema),
        'schema_diff': json.dumps(schema_diff),
        'change_type': change_type,
        'impact_analysis': json.dumps(impact_analysis),
        'expiration_time': timestamp + (90 * 24 * 60 * 60)
    })

def check_agent_memory(schema_diff: Dict, change_type: str) -> bool:
    """Check agent memory for auto-approval"""
    if change_type != "ADDITIVE":
        return False
    try:
        table = dynamodb.Table(AGENT_MEMORY_TABLE)
        pattern = hashlib.md5(json.dumps(schema_diff, sort_keys=True).encode()).hexdigest()
        response = table.query(
            IndexName='SchemaPatternIndex',
            KeyConditionExpression='schema_pattern = :pattern',
            ExpressionAttributeValues={':pattern': pattern},
            Limit=1
        )
        return bool(response['Items'] and response['Items'][0].get('decision') == 'APPROVED')
    except:
        return False
