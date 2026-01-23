# Complete Fix for DynamoDB Issue

## Problem
The `execution_state` DynamoDB table in AWS still has the old schema with `StatusIndex` that requires `start_time` as a Number. The Terraform code is fixed, but the table needs to be recreated.

## Solution: Recreate the DynamoDB Table

### Step 1: Backup Current Data (if any)
```bash
cd ~/schemaguard-ai

# Export existing data (if any)
aws dynamodb scan --table-name schemaguard-ai-dev-execution-state > execution_state_backup.json
```

### Step 2: Destroy and Recreate the Table
```bash
cd terraform

# Target only the execution_state table for recreation
terraform destroy -target=aws_dynamodb_table.execution_state -auto-approve

# Recreate with new schema (no StatusIndex)
terraform apply -target=aws_dynamodb_table.execution_state -auto-approve
```

### Step 3: Verify the Fix
```bash
# Check table schema
aws dynamodb describe-table --table-name schemaguard-ai-dev-execution-state

# Should NOT show StatusIndex in GlobalSecondaryIndexes
```

### Step 4: Test Step Functions
Go to AWS Console and start execution with:
```json
{
  "execution_id": "test-001",
  "s3_bucket": "schemaguard-ai-dev-raw-543927035352",
  "s3_key": "data/demo/01-baseline-single.json",
  "event_time": "2026-01-21T10:00:00Z"
}
```

## Why This Happened
1. Original Terraform had `StatusIndex` with `start_time` as Number
2. We removed `start_time` from Step Functions
3. But the DynamoDB table in AWS still had the old schema
4. Terraform doesn't automatically remove indexes - needs explicit recreation

## Files That Are Correct
✅ `terraform/dynamodb.tf` - No StatusIndex
✅ `step-functions/schemaguard-state-machine.json` - No start_time/end_time
✅ All other files are fine

## This Will Work Because
- Destroying and recreating the table removes the problematic index
- New table will match the Terraform definition (no StatusIndex)
- Step Functions will work without timestamp fields
