"""
Contract Generator Agent
Generates new data contract versions based on approved schema changes.
"""

import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

CONTRACTS_BUCKET = os.environ['CONTRACTS_BUCKET']
CONTRACT_APPROVALS_TABLE = os.environ['CONTRACT_APPROVALS_TABLE']

def lambda_handler(event, context):
    """Generate new contract version"""
    try:
        execution_id = event['execution_id']
        incoming_schema = event['incoming_schema']
        current_contract = event['current_contract']
        schema_diff = event['schema_diff']
        
        print(f"Generating contract for execution: {execution_id}")
        
        # Get current version
        current_version = current_contract.get('version', 0)
        new_version = current_version + 1
        
        # Generate new contract
        new_contract = generate_contract(
            current_contract,
            incoming_schema,
            schema_diff,
            new_version
        )
        
        # Store for approval
        approval_id = store_for_approval(execution_id, new_contract)
        
        return {
            'execution_id': execution_id,
            'approval_id': approval_id,
            'new_contract': new_contract,
            'requires_approval': True,
            'timestamp': datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        raise

def generate_contract(current: Dict, incoming_schema: Dict, diff: Dict, version: int) -> Dict:
    """Generate new contract version"""
    new_contract = {
        "version": version,
        "created_at": datetime.utcnow().isoformat(),
        "description": f"Auto-generated contract v{version} - Schema evolution",
        "schema": incoming_schema,
        "required_fields": current.get('required_fields', []),
        "optional_fields": current.get('optional_fields', []),
        "validation_rules": current.get('validation_rules', {}),
        "evolution_policy": current.get('evolution_policy', 'ADDITIVE_ONLY'),
        "backward_compatible": True,
        "changes": {
            "added_fields": diff.get('added_fields', []),
            "removed_fields": diff.get('removed_fields', []),
            "type_changes": diff.get('type_changes', [])
        },
        "metadata": {
            "owner": current.get('metadata', {}).get('owner', 'data-platform-team'),
            "domain": current.get('metadata', {}).get('domain', 'events'),
            "classification": current.get('metadata', {}).get('classification', 'internal'),
            "previous_version": current.get('version', 0)
        }
    }
    
    # Update optional fields with new additions
    for field in diff.get('added_fields', []):
        field_name = field['field']
        if field_name not in new_contract['optional_fields']:
            new_contract['optional_fields'].append(field_name)
    
    return new_contract

def store_for_approval(execution_id: str, contract: Dict) -> str:
    """Store contract for human approval"""
    table = dynamodb.Table(CONTRACT_APPROVALS_TABLE)
    approval_id = f"approval-{execution_id}"
    timestamp = int(datetime.utcnow().timestamp() * 1000)
    
    table.put_item(Item={
        'approval_id': approval_id,
        'timestamp': timestamp,
        'execution_id': execution_id,
        'contract_version': contract['version'],
        'contract_data': json.dumps(contract),
        'status': 'PENDING',
        'created_at': datetime.utcnow().isoformat(),
        'expiration_time': timestamp + (30 * 24 * 60 * 60)  # 30 days
    })
    
    return approval_id
