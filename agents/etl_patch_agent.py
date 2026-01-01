"""
ETL Patch Agent
Proposes minimal code patches for Glue ETL jobs to handle schema changes.
Uses Amazon Bedrock to generate safe, minimal patches.
"""

import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any

s3_client = boto3.client('s3')
bedrock_runtime = boto3.client('bedrock-runtime')

SCRIPTS_BUCKET = os.environ['SCRIPTS_BUCKET']
BEDROCK_MODEL_ID = os.environ['BEDROCK_MODEL_ID']

def lambda_handler(event, context):
    """Generate ETL patch proposal"""
    try:
        execution_id = event['execution_id']
        schema_diff = event['schema_diff']
        change_type = event['change_type']
        
        print(f"Generating ETL patch for execution: {execution_id}")
        
        # Get current ETL script
        current_script = get_current_etl_script()
        
        # Generate patch with Bedrock
        patch_proposal = generate_patch_with_bedrock(
            current_script,
            schema_diff,
            change_type
        )
        
        # Store patch for review
        patch_key = store_patch_proposal(execution_id, patch_proposal)
        
        return {
            'execution_id': execution_id,
            'patch_proposal': patch_proposal,
            'patch_s3_key': patch_key,
            'requires_review': True,
            'timestamp': datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        raise

def get_current_etl_script() -> str:
    """Retrieve current ETL script from S3"""
    try:
        response = s3_client.get_object(
            Bucket=SCRIPTS_BUCKET,
            Key='glue/etl_job.py'
        )
        return response['Body'].read().decode('utf-8')
    except:
        return ""

def generate_patch_with_bedrock(script: str, diff: Dict, change_type: str) -> Dict:
    """Use Bedrock to generate safe ETL patch"""
    try:
        prompt = f"""You are an ETL code patch generator. Generate a minimal, safe patch for a Glue ETL job.

Current Script:
{script[:1000]}  # Truncated for context

Schema Changes:
- Change Type: {change_type}
- Added Fields: {json.dumps(diff.get('added_fields', []))}
- Removed Fields: {json.dumps(diff.get('removed_fields', []))}
- Type Changes: {json.dumps(diff.get('type_changes', []))}

Requirements:
1. Use AWS Glue DynamicFrame for flexibility
2. Handle missing fields gracefully
3. Add type coercion if needed
4. Preserve existing logic
5. Add error handling

Provide JSON response:
{{
  "patch_type": "FIELD_MAPPING|TYPE_COERCION|ERROR_HANDLING",
  "code_changes": "Python code snippet",
  "explanation": "What this patch does",
  "risk_level": "LOW|MEDIUM|HIGH",
  "testing_required": true/false
}}"""

        response = bedrock_runtime.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 2000,
                "messages": [{"role": "user", "content": prompt}]
            })
        )
        
        result = json.loads(response['body'].read())
        return json.loads(result['content'][0]['text'])
    except Exception as e:
        print(f"Bedrock error: {str(e)}")
        return {
            "patch_type": "MANUAL_REVIEW",
            "code_changes": "# Manual review required",
            "explanation": "Could not auto-generate patch",
            "risk_level": "HIGH",
            "testing_required": True
        }

def store_patch_proposal(execution_id: str, patch: Dict) -> str:
    """Store patch proposal in S3"""
    key = f"patches/patch-{execution_id}.json"
    s3_client.put_object(
        Bucket=SCRIPTS_BUCKET,
        Key=key,
        Body=json.dumps(patch, indent=2),
        ContentType='application/json'
    )
    return key
