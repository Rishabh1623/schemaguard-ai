#!/bin/bash
# SchemaGuard AI - Quick Commands Reference
# Usage: source this file or copy commands as needed

# ============================================
# SETUP ENVIRONMENT
# ============================================

# Set environment variables (CHANGE THESE!)
export PROJECT_NAME="schemaguard-ai"
export ENVIRONMENT="dev"
export AWS_REGION="us-east-1"
export NOTIFICATION_EMAIL="your-email@example.com"  # CHANGE THIS!
export BEDROCK_MODEL="anthropic.claude-3-sonnet-20240229-v1:0"
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Save to file for persistence
cat > ~/.schemaguard-env << EOF
export PROJECT_NAME="${PROJECT_NAME}"
export ENVIRONMENT="${ENVIRONMENT}"
export AWS_REGION="${AWS_REGION}"
export NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL}"
export BEDROCK_MODEL="${BEDROCK_MODEL}"
export ACCOUNT_ID=\$(aws sts get-caller-identity --query Account --output text)
EOF

# Load environment
source ~/.schemaguard-env

# ============================================
# QUICK DEPLOYMENT
# ============================================

# 1. Create all S3 buckets
create_buckets() {
  for bucket in raw staging curated quarantine contracts scripts; do
    aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} --region ${AWS_REGION}
  done
}

# 2. Enable S3 features
configure_s3() {
  # Versioning
  for bucket in raw contracts curated; do
    aws s3api put-bucket-versioning \
      --bucket ${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} \
      --versioning-configuration Status=Enabled
  done
  
  # Encryption
  for bucket in raw staging curated quarantine contracts scripts; do
    aws s3api put-bucket-encryption \
      --bucket ${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} \
      --server-side-encryption-configuration '{
        "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
      }'
  done
  
  # Block public access
  for bucket in raw staging curated quarantine contracts scripts; do
    aws s3api put-public-access-block \
      --bucket ${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} \
      --public-access-block-configuration \
      "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  done
}

# 3. Create DynamoDB tables
create_tables() {
  # Schema History
  aws dynamodb create-table \
    --table-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-history \
    --attribute-definitions \
      AttributeName=schema_id,AttributeType=S \
      AttributeName=timestamp,AttributeType=N \
      AttributeName=data_source,AttributeType=S \
    --key-schema \
      AttributeName=schema_id,KeyType=HASH \
      AttributeName=timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --global-secondary-indexes \
      "[{\"IndexName\":\"DataSourceIndex\",\"KeySchema\":[{\"AttributeName\":\"data_source\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"timestamp\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"}}]"
  
  # Contract Approvals
  aws dynamodb create-table \
    --table-name ${PROJECT_NAME}-${ENVIRONMENT}-contract-approvals \
    --attribute-definitions \
      AttributeName=contract_id,AttributeType=S \
      AttributeName=version,AttributeType=N \
      AttributeName=approval_status,AttributeType=S \
    --key-schema \
      AttributeName=contract_id,KeyType=HASH \
      AttributeName=version,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --global-secondary-indexes \
      "[{\"IndexName\":\"ApprovalStatusIndex\",\"KeySchema\":[{\"AttributeName\":\"approval_status\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"contract_id\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"}}]"
  
  # Agent Memory
  aws dynamodb create-table \
    --table-name ${PROJECT_NAME}-${ENVIRONMENT}-agent-memory \
    --attribute-definitions \
      AttributeName=event_id,AttributeType=S \
      AttributeName=decision_timestamp,AttributeType=N \
      AttributeName=schema_pattern,AttributeType=S \
    --key-schema \
      AttributeName=event_id,KeyType=HASH \
      AttributeName=decision_timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --global-secondary-indexes \
      "[{\"IndexName\":\"SchemaPatternIndex\",\"KeySchema\":[{\"AttributeName\":\"schema_pattern\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"decision_timestamp\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"}}]"
  
  # Execution State
  aws dynamodb create-table \
    --table-name ${PROJECT_NAME}-${ENVIRONMENT}-execution-state \
    --attribute-definitions \
      AttributeName=execution_id,AttributeType=S \
      AttributeName=status,AttributeType=S \
      AttributeName=start_time,AttributeType=N \
    --key-schema \
      AttributeName=execution_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --global-secondary-indexes \
      "[{\"IndexName\":\"StatusIndex\",\"KeySchema\":[{\"AttributeName\":\"status\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"start_time\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"}}]"
}

# 4. Create SNS topic
create_sns() {
  SNS_TOPIC_ARN=$(aws sns create-topic \
    --name ${PROJECT_NAME}-${ENVIRONMENT}-schema-drift-alerts \
    --query 'TopicArn' --output text)
  
  aws sns subscribe \
    --topic-arn $SNS_TOPIC_ARN \
    --protocol email \
    --notification-endpoint $NOTIFICATION_EMAIL
  
  echo "SNS Topic created: $SNS_TOPIC_ARN"
  echo "Check your email to confirm subscription!"
}

# ============================================
# MONITORING COMMANDS
# ============================================

# List all SchemaGuard resources
list_resources() {
  echo "=== S3 Buckets ==="
  aws s3 ls | grep schemaguard
  
  echo -e "\n=== DynamoDB Tables ==="
  aws dynamodb list-tables --query 'TableNames[?contains(@, `schemaguard`)]'
  
  echo -e "\n=== Lambda Functions ==="
  aws lambda list-functions --query 'Functions[?contains(FunctionName, `schemaguard`)].FunctionName'
  
  echo -e "\n=== Step Functions ==="
  aws stepfunctions list-state-machines --query 'stateMachines[?contains(name, `schemaguard`)].name'
}

# View recent Step Functions executions
view_executions() {
  STATE_MACHINE_ARN=$(aws stepfunctions list-state-machines \
    --query 'stateMachines[?contains(name, `schemaguard`)].stateMachineArn' \
    --output text)
  
  aws stepfunctions list-executions \
    --state-machine-arn $STATE_MACHINE_ARN \
    --max-results 10
}

# View Lambda logs
view_logs() {
  FUNCTION_NAME=${1:-"${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer"}
  aws logs tail /aws/lambda/${FUNCTION_NAME} --follow
}

# Check DynamoDB execution state
check_executions() {
  aws dynamodb scan \
    --table-name ${PROJECT_NAME}-${ENVIRONMENT}-execution-state \
    --max-items 5 | jq .
}

# ============================================
# TESTING COMMANDS
# ============================================

# Upload test data
test_baseline() {
  echo '{"id":"test-'$(date +%s)'","timestamp":'$(date +%s)'000,"event_type":"user_action","user_id":"user_123","data":{"action":"click"}}' | \
  aws s3 cp - s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-baseline-$(date +%s).json
  echo "Baseline test data uploaded"
}

test_additive() {
  echo '{"id":"test-'$(date +%s)'","timestamp":'$(date +%s)'000,"event_type":"user_action","user_id":"user_123","data":{"action":"click"},"source_system":"web","environment":"prod"}' | \
  aws s3 cp - s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-additive-$(date +%s).json
  echo "Additive change test data uploaded"
}

test_breaking() {
  echo '{"id":"test-'$(date +%s)'","timestamp":'$(date +%s)'000,"user_id":"user_123","data":{"action":"click"}}' | \
  aws s3 cp - s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-breaking-$(date +%s).json
  echo "Breaking change test data uploaded (missing event_type)"
}

# ============================================
# CLEANUP COMMANDS
# ============================================

# Delete all Lambda functions
delete_lambdas() {
  for func in schema-analyzer contract-generator etl-patch-agent staging-validator; do
    aws lambda delete-function --function-name ${PROJECT_NAME}-${ENVIRONMENT}-${func} 2>/dev/null
    echo "Deleted Lambda: ${func}"
  done
}

# Delete all DynamoDB tables
delete_tables() {
  for table in schema-history contract-approvals agent-memory execution-state; do
    aws dynamodb delete-table --table-name ${PROJECT_NAME}-${ENVIRONMENT}-${table} 2>/dev/null
    echo "Deleted table: ${table}"
  done
}

# Delete all S3 buckets
delete_buckets() {
  for bucket in raw staging curated quarantine contracts scripts; do
    aws s3 rm s3://${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} --recursive 2>/dev/null
    aws s3 rb s3://${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} 2>/dev/null
    echo "Deleted bucket: ${bucket}"
  done
}

# Full cleanup
cleanup_all() {
  echo "WARNING: This will delete ALL SchemaGuard resources!"
  read -p "Are you sure? (yes/no): " confirm
  if [ "$confirm" = "yes" ]; then
    delete_lambdas
    delete_tables
    delete_buckets
    echo "Cleanup complete!"
  else
    echo "Cleanup cancelled"
  fi
}

# ============================================
# UTILITY FUNCTIONS
# ============================================

# Show current configuration
show_config() {
  echo "=== SchemaGuard AI Configuration ==="
  echo "Project Name: $PROJECT_NAME"
  echo "Environment: $ENVIRONMENT"
  echo "AWS Region: $AWS_REGION"
  echo "Account ID: $ACCOUNT_ID"
  echo "Notification Email: $NOTIFICATION_EMAIL"
  echo "Bedrock Model: $BEDROCK_MODEL"
}

# Check AWS CLI configuration
check_aws() {
  echo "=== AWS CLI Status ==="
  aws --version
  echo -e "\nAccount ID: $(aws sts get-caller-identity --query Account --output text)"
  echo "Region: $(aws configure get region)"
  echo "User: $(aws sts get-caller-identity --query Arn --output text)"
}

# Estimate costs
estimate_costs() {
  echo "=== Estimated Monthly Costs ==="
  echo "S3 Storage (100GB): ~$2.30"
  echo "Lambda (10K invocations): ~$0.20"
  echo "Step Functions (1K executions): ~$0.25"
  echo "Glue (50 job runs): ~$22.00"
  echo "DynamoDB (on-demand): ~$5.00"
  echo "Bedrock (100K tokens): ~$3.00"
  echo "Athena (10GB scanned): ~$0.05"
  echo "CloudWatch: ~$2.00"
  echo "----------------------------"
  echo "Total: ~$35/month"
}

# ============================================
# HELP
# ============================================

show_help() {
  echo "SchemaGuard AI - Quick Commands"
  echo ""
  echo "Setup:"
  echo "  source QUICK_COMMANDS.sh        Load this file"
  echo "  show_config                     Show current configuration"
  echo "  check_aws                       Check AWS CLI status"
  echo ""
  echo "Deployment:"
  echo "  create_buckets                  Create all S3 buckets"
  echo "  configure_s3                    Configure S3 features"
  echo "  create_tables                   Create DynamoDB tables"
  echo "  create_sns                      Create SNS topic"
  echo ""
  echo "Monitoring:"
  echo "  list_resources                  List all resources"
  echo "  view_executions                 View Step Functions executions"
  echo "  view_logs [function-name]       View Lambda logs"
  echo "  check_executions                Check execution state"
  echo ""
  echo "Testing:"
  echo "  test_baseline                   Upload baseline test data"
  echo "  test_additive                   Upload additive change test"
  echo "  test_breaking                   Upload breaking change test"
  echo ""
  echo "Cleanup:"
  echo "  delete_lambdas                  Delete Lambda functions"
  echo "  delete_tables                   Delete DynamoDB tables"
  echo "  delete_buckets                  Delete S3 buckets"
  echo "  cleanup_all                     Delete everything"
  echo ""
  echo "Utilities:"
  echo "  estimate_costs                  Show cost estimates"
  echo "  show_help                       Show this help"
}

# Show help by default
show_help
