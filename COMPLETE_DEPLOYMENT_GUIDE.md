# 🚀 SchemaGuard AI - Complete Deployment Guide for AWS Ubuntu

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Setup Instructions](#setup-instructions)
5. [AWS CLI Commands](#aws-cli-commands)
6. [Terraform Deployment](#terraform-deployment)
7. [Agent Code](#agent-code)
8. [Testing](#testing)
9. [Monitoring](#monitoring)
10. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**SchemaGuard AI** is an agent-driven ETL reliability platform that:
- Detects schema drift in S3 data automatically
- Uses Amazon Bedrock AI for impact analysis
- Proposes and validates schema changes
- Controls production execution with governance

**Problem Solved:** Prevents ETL failures from schema changes, reduces incident response from hours to minutes.

---

## ✅ Prerequisites

### 1. AWS Account Setup
```bash
# Verify AWS CLI is installed
aws --version
# Should show: aws-cli/2.x.x

# Configure AWS credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Verify configuration
aws sts get-caller-identity
```

### 2. Install Required Tools on Ubuntu
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.11
sudo apt install python3.11 python3.11-venv python3-pip -y

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# Install jq for JSON processing
sudo apt install jq zip unzip -y

# Verify installations
terraform --version
python3.11 --version
jq --version
```

### 3. Enable Amazon Bedrock
```bash
# Check Bedrock model availability
aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[?contains(modelId, `claude-3-sonnet`)].modelId'

# If empty, enable via AWS Console:
# 1. Navigate to: https://console.aws.amazon.com/bedrock/
# 2. Click "Model access" → "Manage model access"
# 3. Enable "Anthropic Claude 3 Sonnet"
# 4. Submit request (usually instant approval)
```

---

## 🏗️ Architecture

### High-Level Flow
```
S3 Raw Data → EventBridge → Step Functions (Agent Orchestrator)
                                    ↓
                    ┌───────────────────────────────┐
                    │  Agent Workflow               │
                    ├───────────────────────────────┤
                    │  1. Schema Analyzer (Lambda)  │
                    │  2. Contract Generator        │
                    │  3. ETL Patch Agent           │
                    │  4. Staging Validator         │
                    │  5. Production Executor       │
                    └───────────────────────────────┘
                                    ↓
                    Staging → Validation → Production
```

### AWS Resources (30+)
- **6 S3 Buckets**: raw, staging, curated, quarantine, contracts, scripts
- **4 Lambda Functions**: schema_analyzer, contract_generator, etl_patch_agent, staging_validator
- **4 DynamoDB Tables**: schema_history, contract_approvals, agent_memory, execution_state
- **1 Step Functions**: Agent orchestration workflow
- **1 Glue Job**: ETL processing
- **1 SNS Topic**: Notifications
- **4 IAM Roles**: Security and permissions

---

## 🚀 Setup Instructions

### Step 1: Create Project Directory
```bash
# Create project structure
mkdir -p ~/schemaguard-ai/{terraform,step-functions,agents,glue,contracts,tests,docs}
cd ~/schemaguard-ai

# Verify structure
tree -L 1
```

### Step 2: Set Environment Variables
```bash
# Create environment file
cat > ~/.schemaguard-env << 'EOF'
export PROJECT_NAME="schemaguard-ai"
export ENVIRONMENT="dev"
export AWS_REGION="us-east-1"
export NOTIFICATION_EMAIL="your-email@example.com"  # CHANGE THIS
export BEDROCK_MODEL="anthropic.claude-3-sonnet-20240229-v1:0"
EOF

# Load environment
source ~/.schemaguard-env

# Add to .bashrc for persistence
echo "source ~/.schemaguard-env" >> ~/.bashrc
```

---

## 📝 AWS CLI Commands

### Create S3 Buckets
```bash
# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create buckets
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID} --region ${AWS_REGION}
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-staging-${ACCOUNT_ID} --region ${AWS_REGION}
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-curated-${ACCOUNT_ID} --region ${AWS_REGION}
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-quarantine-${ACCOUNT_ID} --region ${AWS_REGION}
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID} --region ${AWS_REGION}
aws s3 mb s3://${PROJECT_NAME}-${ENVIRONMENT}-scripts-${ACCOUNT_ID} --region ${AWS_REGION}

# Enable versioning on critical buckets
aws s3api put-bucket-versioning --bucket ${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID} --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket ${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID} --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket ${PROJECT_NAME}-${ENVIRONMENT}-curated-${ACCOUNT_ID} --versioning-configuration Status=Enabled

# Enable encryption
for bucket in raw staging curated quarantine contracts scripts; do
  aws s3api put-bucket-encryption \
    --bucket ${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }'
done

# Block public access
for bucket in raw staging curated quarantine contracts scripts; do
  aws s3api put-public-access-block \
    --bucket ${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
done

# Enable EventBridge notifications on raw bucket
aws s3api put-bucket-notification-configuration \
  --bucket ${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID} \
  --notification-configuration '{
    "EventBridgeConfiguration": {}
  }'

# Verify buckets
aws s3 ls | grep schemaguard
```

### Create DynamoDB Tables
```bash
# Schema History Table
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
    "[{
      \"IndexName\": \"DataSourceIndex\",
      \"KeySchema\": [{\"AttributeName\":\"data_source\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"timestamp\",\"KeyType\":\"RANGE\"}],
      \"Projection\": {\"ProjectionType\":\"ALL\"}
    }]" \
  --tags Key=Project,Value=SchemaGuard-AI Key=Environment,Value=${ENVIRONMENT}

# Contract Approvals Table
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
    "[{
      \"IndexName\": \"ApprovalStatusIndex\",
      \"KeySchema\": [{\"AttributeName\":\"approval_status\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"contract_id\",\"KeyType\":\"RANGE\"}],
      \"Projection\": {\"ProjectionType\":\"ALL\"}
    }]" \
  --tags Key=Project,Value=SchemaGuard-AI

# Agent Memory Table
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
    "[{
      \"IndexName\": \"SchemaPatternIndex\",
      \"KeySchema\": [{\"AttributeName\":\"schema_pattern\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"decision_timestamp\",\"KeyType\":\"RANGE\"}],
      \"Projection\": {\"ProjectionType\":\"ALL\"}
    }]" \
  --tags Key=Project,Value=SchemaGuard-AI

# Execution State Table
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
    "[{
      \"IndexName\": \"StatusIndex\",
      \"KeySchema\": [{\"AttributeName\":\"status\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"start_time\",\"KeyType\":\"RANGE\"}],
      \"Projection\": {\"ProjectionType\":\"ALL\"}
    }]" \
  --tags Key=Project,Value=SchemaGuard-AI

# Enable TTL on tables
aws dynamodb update-time-to-live \
  --table-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-history \
  --time-to-live-specification "Enabled=true, AttributeName=expiration_time"

aws dynamodb update-time-to-live \
  --table-name ${PROJECT_NAME}-${ENVIRONMENT}-agent-memory \
  --time-to-live-specification "Enabled=true, AttributeName=expiration_time"

aws dynamodb update-time-to-live \
  --table-name ${PROJECT_NAME}-${ENVIRONMENT}-execution-state \
  --time-to-live-specification "Enabled=true, AttributeName=expiration_time"

# Verify tables
aws dynamodb list-tables --query 'TableNames[?contains(@, `schemaguard`)]'
```

### Create SNS Topic
```bash
# Create SNS topic
SNS_TOPIC_ARN=$(aws sns create-topic \
  --name ${PROJECT_NAME}-${ENVIRONMENT}-schema-drift-alerts \
  --tags Key=Project,Value=SchemaGuard-AI \
  --query 'TopicArn' --output text)

echo "SNS Topic ARN: $SNS_TOPIC_ARN"

# Subscribe email
aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint $NOTIFICATION_EMAIL

echo "Check your email and confirm the SNS subscription!"

# Save ARN for later use
echo "export SNS_TOPIC_ARN=$SNS_TOPIC_ARN" >> ~/.schemaguard-env
```

---

## 🔧 Terraform Deployment

### Option 1: Using Terraform (Recommended)

```bash
cd ~/schemaguard-ai/terraform

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project_name      = "${PROJECT_NAME}"
environment       = "${ENVIRONMENT}"
aws_region        = "${AWS_REGION}"
notification_email = "${NOTIFICATION_EMAIL}"
bedrock_model_id  = "${BEDROCK_MODEL}"
EOF

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply (creates all resources)
terraform apply -auto-approve

# Save outputs
terraform output > ../deployment-outputs.txt
```

### Option 2: Manual AWS CLI (If Terraform not preferred)

All AWS CLI commands are provided in the sections above. Follow them sequentially.

---

## 🤖 Agent Code

### Create Python Virtual Environment
```bash
cd ~/schemaguard-ai/agents

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Create requirements.txt
cat > requirements.txt << 'EOF'
boto3>=1.34.0
botocore>=1.34.0
EOF

# Install dependencies
pip install -r requirements.txt
```

### Package Lambda Functions
```bash
cd ~/schemaguard-ai/agents

# Install dependencies to package directory
pip install -r requirements.txt -t package/

# Package schema_analyzer
cd package && zip -r ../schema_analyzer.zip . && cd ..
zip -g schema_analyzer.zip schema_analyzer.py

# Package contract_generator
cd package && zip -r ../contract_generator.zip . && cd ..
zip -g contract_generator.zip contract_generator.py

# Package etl_patch_agent
cd package && zip -r ../etl_patch_agent.zip . && cd ..
zip -g etl_patch_agent.zip etl_patch_agent.py

# Package staging_validator
cd package && zip -r ../staging_validator.zip . && cd ..
zip -g staging_validator.zip staging_validator.py

# Clean up
rm -rf package

# Verify packages
ls -lh *.zip
```

### Deploy Lambda Functions via AWS CLI
```bash
# Get IAM role ARN (create if using Terraform, or create manually)
LAMBDA_ROLE_ARN=$(aws iam get-role --role-name ${PROJECT_NAME}-${ENVIRONMENT}-lambda-agent-role --query 'Role.Arn' --output text)

# Deploy schema_analyzer
aws lambda create-function \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer \
  --runtime python3.11 \
  --role $LAMBDA_ROLE_ARN \
  --handler schema_analyzer.lambda_handler \
  --zip-file fileb://schema_analyzer.zip \
  --timeout 300 \
  --memory-size 512 \
  --environment "Variables={
    SCHEMA_HISTORY_TABLE=${PROJECT_NAME}-${ENVIRONMENT}-schema-history,
    AGENT_MEMORY_TABLE=${PROJECT_NAME}-${ENVIRONMENT}-agent-memory,
    CONTRACTS_BUCKET=${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID},
    BEDROCK_MODEL_ID=${BEDROCK_MODEL},
    ENVIRONMENT=${ENVIRONMENT}
  }"

# Deploy contract_generator
aws lambda create-function \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-contract-generator \
  --runtime python3.11 \
  --role $LAMBDA_ROLE_ARN \
  --handler contract_generator.lambda_handler \
  --zip-file fileb://contract_generator.zip \
  --timeout 300 \
  --memory-size 512 \
  --environment "Variables={
    CONTRACT_APPROVALS_TABLE=${PROJECT_NAME}-${ENVIRONMENT}-contract-approvals,
    CONTRACTS_BUCKET=${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID},
    BEDROCK_MODEL_ID=${BEDROCK_MODEL},
    ENVIRONMENT=${ENVIRONMENT}
  }"

# Deploy etl_patch_agent
aws lambda create-function \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-etl-patch-agent \
  --runtime python3.11 \
  --role $LAMBDA_ROLE_ARN \
  --handler etl_patch_agent.lambda_handler \
  --zip-file fileb://etl_patch_agent.zip \
  --timeout 300 \
  --memory-size 512 \
  --environment "Variables={
    SCRIPTS_BUCKET=${PROJECT_NAME}-${ENVIRONMENT}-scripts-${ACCOUNT_ID},
    BEDROCK_MODEL_ID=${BEDROCK_MODEL},
    ENVIRONMENT=${ENVIRONMENT}
  }"

# Deploy staging_validator
aws lambda create-function \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-staging-validator \
  --runtime python3.11 \
  --role $LAMBDA_ROLE_ARN \
  --handler staging_validator.lambda_handler \
  --zip-file fileb://staging_validator.zip \
  --timeout 600 \
  --memory-size 1024 \
  --environment "Variables={
    STAGING_BUCKET=${PROJECT_NAME}-${ENVIRONMENT}-staging-${ACCOUNT_ID},
    CURATED_BUCKET=${PROJECT_NAME}-${ENVIRONMENT}-curated-${ACCOUNT_ID},
    ATHENA_DATABASE=${PROJECT_NAME}_${ENVIRONMENT}_database,
    ATHENA_OUTPUT=s3://${PROJECT_NAME}-${ENVIRONMENT}-staging-${ACCOUNT_ID}/athena-results/,
    ENVIRONMENT=${ENVIRONMENT}
  }"

# Verify Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `schemaguard`)].FunctionName'
```

---

## 📄 Create Data Contracts

```bash
cd ~/schemaguard-ai/contracts

# Create contract v1
cat > contract_v1.json << 'EOF'
{
  "version": 1,
  "created_at": "2025-12-31T00:00:00Z",
  "description": "Initial data contract for SchemaGuard AI platform",
  "schema": {
    "type": "object",
    "properties": {
      "id": {"type": "string"},
      "timestamp": {"type": "integer"},
      "event_type": {"type": "string"},
      "user_id": {"type": "string"},
      "data": {"type": "object"}
    }
  },
  "required_fields": ["id", "timestamp", "event_type"],
  "optional_fields": ["user_id", "data"],
  "evolution_policy": "ADDITIVE_ONLY"
}
EOF

# Upload to S3
aws s3 cp contract_v1.json s3://${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID}/contract_v1.json

# Verify upload
aws s3 ls s3://${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID}/
```

---

## 🧪 Testing

### Create Test Data
```bash
cd ~/schemaguard-ai/tests

# Baseline test data (matches contract v1)
cat > sample-data-baseline.json << 'EOF'
{
  "id": "evt-001-baseline",
  "timestamp": 1735689600000,
  "event_type": "user_action",
  "user_id": "user_12345",
  "data": {
    "action": "click",
    "target": "button_submit"
  }
}
EOF

# Additive change test data (new fields)
cat > sample-data-additive.json << 'EOF'
{
  "id": "evt-002-additive",
  "timestamp": 1735689600000,
  "event_type": "user_action",
  "user_id": "user_12345",
  "data": {
    "action": "click",
    "target": "button_submit"
  },
  "source_system": "web_app",
  "environment": "prod"
}
EOF

# Breaking change test data (missing required field)
cat > sample-data-breaking.json << 'EOF'
{
  "id": "evt-003-breaking",
  "timestamp": 1735689600000,
  "user_id": "user_12345",
  "data": {
    "action": "click",
    "target": "button_submit"
  }
}
EOF
```

### Run Tests
```bash
# Test 1: Baseline (should pass)
aws s3 cp sample-data-baseline.json s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-baseline-$(date +%s).json

# Test 2: Additive change (should trigger contract proposal)
aws s3 cp sample-data-additive.json s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-additive-$(date +%s).json

# Test 3: Breaking change (should quarantine)
aws s3 cp sample-data-breaking.json s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/test-breaking-$(date +%s).json
```

---

## 📊 Monitoring

### View Step Functions Executions
```bash
# Get state machine ARN
STATE_MACHINE_ARN=$(aws stepfunctions list-state-machines --query 'stateMachines[?contains(name, `schemaguard`)].stateMachineArn' --output text)

# List recent executions
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --max-results 10

# Get execution details
EXECUTION_ARN="<execution-arn-from-above>"
aws stepfunctions describe-execution --execution-arn $EXECUTION_ARN
```

### View Lambda Logs
```bash
# View schema analyzer logs
aws logs tail /aws/lambda/${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer --follow

# View recent log events
aws logs filter-log-events \
  --log-group-name /aws/lambda/${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --limit 50
```

### Check DynamoDB Data
```bash
# View execution state
aws dynamodb scan \
  --table-name ${PROJECT_NAME}-${ENVIRONMENT}-execution-state \
  --max-items 5

# View schema history
aws dynamodb scan \
  --table-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-history \
  --max-items 5
```

### Check S3 Buckets
```bash
# List files in raw bucket
aws s3 ls s3://${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}/data/ --recursive

# List quarantined files
aws s3 ls s3://${PROJECT_NAME}-${ENVIRONMENT}-quarantine-${ACCOUNT_ID}/ --recursive

# List curated files
aws s3 ls s3://${PROJECT_NAME}-${ENVIRONMENT}-curated-${ACCOUNT_ID}/data/ --recursive
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Bedrock Access Denied
```bash
# Check model access
aws bedrock list-foundation-models --region us-east-1 | grep claude-3-sonnet

# If empty, enable via Console:
# https://console.aws.amazon.com/bedrock/home#/modelaccess
```

#### 2. Lambda Timeout
```bash
# Increase timeout
aws lambda update-function-configuration \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer \
  --timeout 600
```

#### 3. IAM Permission Issues
```bash
# Check Lambda role
aws iam get-role --role-name ${PROJECT_NAME}-${ENVIRONMENT}-lambda-agent-role

# List attached policies
aws iam list-attached-role-policies --role-name ${PROJECT_NAME}-${ENVIRONMENT}-lambda-agent-role
```

#### 4. EventBridge Not Triggering
```bash
# Check EventBridge rule
aws events list-rules --name-prefix ${PROJECT_NAME}

# Check rule targets
aws events list-targets-by-rule --rule ${PROJECT_NAME}-${ENVIRONMENT}-s3-object-created
```

### Useful Commands

```bash
# View all SchemaGuard resources
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=SchemaGuard-AI \
  --query 'ResourceTagMappingList[].ResourceARN'

# Check Lambda function status
aws lambda get-function --function-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer

# Test Lambda function
aws lambda invoke \
  --function-name ${PROJECT_NAME}-${ENVIRONMENT}-schema-analyzer \
  --payload '{"execution_id":"test-123","s3_bucket":"test","s3_key":"test.json","event_time":"2025-12-31T00:00:00Z"}' \
  response.json

# View response
cat response.json | jq .
```

---

## 🧹 Cleanup

### Delete All Resources
```bash
# Delete Lambda functions
for func in schema-analyzer contract-generator etl-patch-agent staging-validator; do
  aws lambda delete-function --function-name ${PROJECT_NAME}-${ENVIRONMENT}-${func}
done

# Delete DynamoDB tables
for table in schema-history contract-approvals agent-memory execution-state; do
  aws dynamodb delete-table --table-name ${PROJECT_NAME}-${ENVIRONMENT}-${table}
done

# Empty and delete S3 buckets
for bucket in raw staging curated quarantine contracts scripts; do
  aws s3 rm s3://${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID} --recursive
  aws s3 rb s3://${PROJECT_NAME}-${ENVIRONMENT}-${bucket}-${ACCOUNT_ID}
done

# Delete SNS topic
aws sns delete-topic --topic-arn $SNS_TOPIC_ARN

# Or use Terraform
cd ~/schemaguard-ai/terraform
terraform destroy -auto-approve
```

---

## 📚 Quick Reference

### Environment Variables
```bash
source ~/.schemaguard-env
echo $PROJECT_NAME
echo $AWS_REGION
echo $ACCOUNT_ID
```

### Bucket Names
```bash
RAW_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-raw-${ACCOUNT_ID}"
STAGING_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-staging-${ACCOUNT_ID}"
CURATED_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-curated-${ACCOUNT_ID}"
QUARANTINE_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-quarantine-${ACCOUNT_ID}"
CONTRACTS_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-contracts-${ACCOUNT_ID}"
SCRIPTS_BUCKET="${PROJECT_NAME}-${ENVIRONMENT}-scripts-${ACCOUNT_ID}"
```

### Table Names
```bash
SCHEMA_HISTORY_TABLE="${PROJECT_NAME}-${ENVIRONMENT}-schema-history"
CONTRACT_APPROVALS_TABLE="${PROJECT_NAME}-${ENVIRONMENT}-contract-approvals"
AGENT_MEMORY_TABLE="${PROJECT_NAME}-${ENVIRONMENT}-agent-memory"
EXECUTION_STATE_TABLE="${PROJECT_NAME}-${ENVIRONMENT}-execution-state"
```

---

## 🎯 Success Checklist

- [ ] AWS CLI configured
- [ ] Python 3.11 installed
- [ ] Terraform installed
- [ ] Bedrock access enabled
- [ ] S3 buckets created
- [ ] DynamoDB tables created
- [ ] SNS topic created and subscribed
- [ ] Lambda functions deployed
- [ ] Data contract uploaded
- [ ] Test data uploaded
- [ ] Step Functions execution verified
- [ ] CloudWatch logs accessible

---

## 💡 Tips

1. **Always source environment file**: `source ~/.schemaguard-env`
2. **Use jq for JSON**: `aws dynamodb scan --table-name ... | jq .`
3. **Monitor costs**: `aws ce get-cost-and-usage --time-period Start=2025-12-01,End=2025-12-31 --granularity MONTHLY --metrics BlendedCost`
4. **Check quotas**: `aws service-quotas list-service-quotas --service-code lambda`
5. **Enable CloudTrail**: For audit logging of all API calls

---

## 📞 Support

### AWS Console URLs
- **Step Functions**: https://console.aws.amazon.com/states/home?region=us-east-1
- **Lambda**: https://console.aws.amazon.com/lambda/home?region=us-east-1
- **DynamoDB**: https://console.aws.amazon.com/dynamodb/home?region=us-east-1
- **S3**: https://console.aws.amazon.com/s3/home?region=us-east-1
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1
- **Bedrock**: https://console.aws.amazon.com/bedrock/home?region=us-east-1

### Documentation
- AWS CLI: https://docs.aws.amazon.com/cli/
- Terraform: https://www.terraform.io/docs
- Bedrock: https://docs.aws.amazon.com/bedrock/

---

## 🎉 Congratulations!

You now have a complete guide for deploying SchemaGuard AI on AWS Ubuntu using AWS CLI and Console!

**Estimated Deployment Time:** 30-45 minutes  
**Monthly Cost:** $30-50 (moderate usage)  
**Status:** Production-ready infrastructure  

---

*Last Updated: December 31, 2025*  
*Version: 1.0*  
*Platform: AWS Ubuntu + AWS CLI*
