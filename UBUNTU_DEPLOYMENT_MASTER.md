# 🚀 SchemaGuard AI - Complete Ubuntu Deployment Guide

## 📋 Single File Reference for AWS Ubuntu + Terraform Deployment

**Environment:** AWS Ubuntu EC2 Server  
**Tools:** Terraform, AWS CLI, Python  
**Time:** 30-45 minutes  
**Difficulty:** Intermediate  

---

## ✅ PART 1: PREREQUISITES & SETUP (10 minutes)

### Step 1.1: Launch AWS Ubuntu EC2 Instance

**Option A: AWS Console**
1. Go to EC2 Dashboard
2. Click "Launch Instance"
3. Choose: Ubuntu Server 22.04 LTS
4. Instance type: t3.medium (minimum)
5. Key pair: Create or select existing
6. Security group: Allow SSH (port 22)
7. Storage: 30 GB gp3
8. Launch instance

**Option B: AWS CLI**
```bash
aws ec2 run-instances \
  --image-id ami-0c7217cdde317cfec \
  --instance-type t3.medium \
  --key-name your-key-name \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":30}}]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=SchemaGuard-Deploy}]'
```

### Step 1.2: Connect to Ubuntu Server

```bash
# From your local machine
ssh -i your-key.pem ubuntu@your-ec2-public-ip

# Once connected, update system
sudo apt update && sudo apt upgrade -y
```

### Step 1.3: Install Required Tools

**Install AWS CLI**
```bash
# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
# Should show: aws-cli/2.x.x
```

**Install Terraform**
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update
sudo apt install terraform -y

# Verify installation
terraform --version
# Should show: Terraform v1.5.x or higher
```

**Install Python 3.11+**
```bash
# Ubuntu 22.04 comes with Python 3.10, upgrade to 3.11
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3-pip -y

# Verify installation
python3.11 --version
# Should show: Python 3.11.x
```

**Install Git**
```bash
sudo apt install git -y
git --version
```

### Step 1.4: Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Enter when prompted:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1 (or your preferred region)
# Default output format: json

# Verify configuration
aws sts get-caller-identity
# Should show your account ID, user ARN
```

### Step 1.5: Enable Amazon Bedrock Access

```bash
# Check Bedrock model access (must do in AWS Console)
echo "⚠️  IMPORTANT: Enable Bedrock access in AWS Console"
echo "1. Go to: https://console.aws.amazon.com/bedrock/"
echo "2. Click 'Model access' in left menu"
echo "3. Click 'Manage model access'"
echo "4. Enable 'Anthropic Claude 3 Sonnet'"
echo "5. Click 'Save changes'"
echo ""
echo "Press Enter after enabling Bedrock access..."
read
```

---

## ✅ PART 2: CLONE & PREPARE PROJECT (5 minutes)

### Step 2.1: Clone Repository

```bash
# Clone from GitHub
cd ~
git clone https://github.com/Rishabh1623/schemaguard-ai.git
cd schemaguard-ai

# Verify files
ls -la
# Should see: terraform/, agents/, contracts/, tests/, docs/
```

### Step 2.2: Configure Terraform Variables

```bash
# Copy example configuration
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

**Update these values in terraform.tfvars:**
```hcl
# REQUIRED: Change this to your email
notification_email = "your-email@example.com"

# OPTIONAL: Customize if needed
project_name = "schemaguard-ai"
environment  = "dev"
aws_region   = "us-east-1"

# Cost optimization (keep defaults for dev)
glue_worker_type       = "G.1X"
glue_number_of_workers = 2
quarantine_retention_days = 30
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

### Step 2.3: Review Configuration

```bash
# Check your configuration
cat terraform.tfvars

# Verify email is updated
grep "notification_email" terraform.tfvars
```

---

## ✅ PART 3: DEPLOY INFRASTRUCTURE (15 minutes)

### Step 3.1: Initialize Terraform

```bash
# Still in terraform/ directory
terraform init

# Expected output:
# - Downloading AWS provider
# - Downloading Archive provider
# - Terraform has been successfully initialized!
```

**What this does:**
- Downloads required providers (AWS, Archive)
- Initializes backend (local state)
- Prepares working directory

### Step 3.2: Validate Configuration

```bash
# Validate Terraform syntax
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 3.3: Plan Deployment

```bash
# Generate execution plan
terraform plan

# Review output - should show:
# - Plan: 30+ to add, 0 to change, 0 to destroy
```

**What will be created:**
- 6 S3 buckets (raw, staging, curated, quarantine, contracts, scripts)
- 4 DynamoDB tables (schema-history, contract-approvals, agent-memory, execution-state)
- 4 Lambda functions (schema-analyzer, contract-generator, etl-patch-agent, staging-validator)
- 1 Step Functions state machine
- 1 Glue job + database
- 1 SNS topic
- 4 IAM roles with policies
- CloudWatch log groups
- EventBridge rules

### Step 3.4: Deploy Infrastructure

```bash
# Apply configuration
terraform apply

# Review plan, then type: yes

# ⏱️  This takes 10-15 minutes
# Watch the progress - resources will be created one by one
```

**Expected output:**
```
Apply complete! Resources: 30+ added, 0 changed, 0 destroyed.

Outputs:
raw_bucket_name = "schemaguard-ai-dev-raw-123456789"
curated_bucket_name = "schemaguard-ai-dev-curated-123456789"
...
```

### Step 3.5: Save Outputs

```bash
# Save outputs to file for reference
terraform output > ../deployment-outputs.txt

# View outputs
cat ../deployment-outputs.txt
```

---

## ✅ PART 4: VERIFY DEPLOYMENT (5 minutes)

### Step 4.1: Check S3 Buckets

```bash
# List all SchemaGuard buckets
aws s3 ls | grep schemaguard

# Expected output: 6 buckets
# schemaguard-ai-dev-raw-...
# schemaguard-ai-dev-staging-...
# schemaguard-ai-dev-curated-...
# schemaguard-ai-dev-quarantine-...
# schemaguard-ai-dev-contracts-...
# schemaguard-ai-dev-scripts-...
```

### Step 4.2: Check DynamoDB Tables

```bash
# List all SchemaGuard tables
aws dynamodb list-tables | grep schemaguard

# Expected output: 4 tables
# schemaguard-ai-dev-schema-history
# schemaguard-ai-dev-contract-approvals
# schemaguard-ai-dev-agent-memory
# schemaguard-ai-dev-execution-state
```

### Step 4.3: Check Lambda Functions

```bash
# List all SchemaGuard Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `schemaguard`)].FunctionName'

# Expected output: 4 functions
# schemaguard-ai-dev-schema-analyzer
# schemaguard-ai-dev-contract-generator
# schemaguard-ai-dev-etl-patch-agent
# schemaguard-ai-dev-staging-validator
```

### Step 4.4: Check Step Functions

```bash
# List Step Functions state machines
aws stepfunctions list-state-machines | grep schemaguard

# Expected output: 1 state machine
# schemaguard-ai-dev-orchestrator
```

### Step 4.5: Confirm SNS Subscription

```bash
echo "📧 Check your email for SNS subscription confirmation"
echo "Subject: AWS Notification - Subscription Confirmation"
echo "Click the 'Confirm subscription' link in the email"
echo ""
echo "Press Enter after confirming..."
read
```

---

## ✅ PART 5: UPLOAD INITIAL DATA (3 minutes)

### Step 5.1: Get Bucket Names

```bash
# Go back to project root
cd ~/schemaguard-ai

# Get bucket names from Terraform output
CONTRACTS_BUCKET=$(cd terraform && terraform output -raw contracts_bucket_name)
RAW_BUCKET=$(cd terraform && terraform output -raw raw_bucket_name)
SCRIPTS_BUCKET=$(cd terraform && terraform output -raw scripts_bucket_name)

# Verify
echo "Contracts bucket: $CONTRACTS_BUCKET"
echo "Raw bucket: $RAW_BUCKET"
echo "Scripts bucket: $SCRIPTS_BUCKET"
```

### Step 5.2: Upload Data Contract

```bash
# Upload initial contract
aws s3 cp contracts/contract_v1.json s3://$CONTRACTS_BUCKET/contract_v1.json

# Verify upload
aws s3 ls s3://$CONTRACTS_BUCKET/
# Should show: contract_v1.json
```

### Step 5.3: Upload Glue ETL Script

```bash
# Upload Glue job script
aws s3 cp glue/etl_job.py s3://$SCRIPTS_BUCKET/glue/etl_job.py

# Verify upload
aws s3 ls s3://$SCRIPTS_BUCKET/glue/
# Should show: etl_job.py
```

---

## ✅ PART 6: TEST THE SYSTEM (5 minutes)

### Step 6.1: Upload Test Data

```bash
# Upload baseline test data
aws s3 cp tests/sample-data-baseline.json s3://$RAW_BUCKET/data/test-$(date +%s).json

# Verify upload
aws s3 ls s3://$RAW_BUCKET/data/
```

### Step 6.2: Monitor Step Functions Execution

```bash
# Get Step Functions ARN
STATE_MACHINE_ARN=$(cd terraform && terraform output -raw step_functions_arn)

# List recent executions
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --max-results 5

# Get execution ARN from output, then describe it
EXECUTION_ARN="<paste-execution-arn-here>"
aws stepfunctions describe-execution --execution-arn $EXECUTION_ARN
```

### Step 6.3: Check Lambda Logs

```bash
# View Schema Analyzer logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# Press Ctrl+C to stop following logs
```

### Step 6.4: Check Results

```bash
# Check curated bucket for processed data
CURATED_BUCKET=$(cd terraform && terraform output -raw curated_bucket_name)
aws s3 ls s3://$CURATED_BUCKET/data/ --recursive

# Check DynamoDB for schema history
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 5
```

---

## ✅ PART 7: TEST SCHEMA DRIFT DETECTION (5 minutes)

### Step 7.1: Create Test File with Schema Change

```bash
# Create test file with new field
cat > /tmp/test-drift.json << 'EOF'
{
  "id": "test-drift-001",
  "timestamp": 1704067200000,
  "event_type": "user_action",
  "user_id": "user-123",
  "user_location": "New York",
  "data": {
    "action": "click",
    "target": "button"
  }
}
EOF

# View the file
cat /tmp/test-drift.json
```

### Step 7.2: Upload Drift Test

```bash
# Upload file with schema drift
aws s3 cp /tmp/test-drift.json s3://$RAW_BUCKET/data/drift-test-$(date +%s).json

echo "✅ Uploaded test file with new field: user_location"
```

### Step 7.3: Monitor Drift Detection

```bash
# Wait 30 seconds for processing
sleep 30

# Check latest execution
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --max-results 1

# View logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 5m
```

---

## ✅ PART 8: MONITORING & TROUBLESHOOTING

### Monitor CloudWatch Logs

```bash
# Schema Analyzer
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# Contract Generator
aws logs tail /aws/lambda/schemaguard-ai-dev-contract-generator --follow

# Step Functions
aws logs tail /aws/vendedlogs/states/schemaguard-ai-dev-orchestrator --follow

# Glue Job
aws logs tail /aws-glue/jobs/schemaguard-ai-dev-etl-job --follow
```

### Check Resource Status

```bash
# Lambda function status
aws lambda get-function --function-name schemaguard-ai-dev-schema-analyzer \
  --query 'Configuration.State'

# Step Functions status
aws stepfunctions describe-state-machine --state-machine-arn $STATE_MACHINE_ARN \
  --query 'status'

# DynamoDB table status
aws dynamodb describe-table --table-name schemaguard-ai-dev-schema-history \
  --query 'Table.TableStatus'
```

### Common Issues & Solutions

**Issue 1: Bedrock Access Denied**
```bash
# Solution: Enable Bedrock in AWS Console
echo "Go to: https://console.aws.amazon.com/bedrock/"
echo "Enable Claude 3 Sonnet model access"
```

**Issue 2: Lambda Function Fails**
```bash
# Check logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 1h

# Check IAM permissions
aws lambda get-function --function-name schemaguard-ai-dev-schema-analyzer \
  --query 'Configuration.Role'
```

**Issue 3: Step Functions Not Triggering**
```bash
# Check EventBridge rule
aws events list-rules | grep schemaguard

# Check S3 event notifications
aws s3api get-bucket-notification-configuration --bucket $RAW_BUCKET
```

---

## ✅ PART 9: COST MONITORING

### Check Current Costs

```bash
# Get cost for last 7 days
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '7 days ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=SERVICE

# Expected costs (dev environment):
# - S3: $1-2/month
# - Lambda: $1-2/month
# - DynamoDB: $1-2/month
# - Step Functions: $1/month
# - Glue: $0 (on-demand)
# - Bedrock: $2-3/month
# Total: $7-12/month
```

### Set Up Cost Alerts (Optional)

```bash
# Create budget alert
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget.json

# budget.json content:
cat > budget.json << 'EOF'
{
  "BudgetName": "SchemaGuard-Monthly",
  "BudgetLimit": {
    "Amount": "20",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
EOF
```

---

## ✅ PART 10: CLEANUP (When Done Testing)

### Option A: Destroy Everything

```bash
# Go to terraform directory
cd ~/schemaguard-ai/terraform

# Destroy all resources
terraform destroy

# Type: yes

# ⏱️  This takes 5-10 minutes
```

### Option B: Keep Infrastructure, Clean Data

```bash
# Empty S3 buckets (keeps buckets)
aws s3 rm s3://$RAW_BUCKET --recursive
aws s3 rm s3://$STAGING_BUCKET --recursive
aws s3 rm s3://$CURATED_BUCKET --recursive
aws s3 rm s3://$QUARANTINE_BUCKET --recursive

# Clear DynamoDB tables (keeps tables)
# Note: This requires scanning and deleting items individually
```

---

## 📊 QUICK REFERENCE COMMANDS

### Deployment
```bash
cd ~/schemaguard-ai/terraform
terraform init
terraform plan
terraform apply
```

### Upload Data
```bash
aws s3 cp contracts/contract_v1.json s3://$CONTRACTS_BUCKET/
aws s3 cp tests/sample-data-baseline.json s3://$RAW_BUCKET/data/
```

### Monitor
```bash
# Step Functions
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN

# Lambda Logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# S3 Contents
aws s3 ls s3://$RAW_BUCKET/data/
aws s3 ls s3://$CURATED_BUCKET/data/
```

### Cleanup
```bash
cd ~/schemaguard-ai/terraform
terraform destroy
```

---

## 🎯 SUCCESS CRITERIA

Your deployment is successful when:

- ✅ All 30+ resources created without errors
- ✅ SNS subscription confirmed via email
- ✅ Test data uploaded successfully
- ✅ Step Functions execution completes
- ✅ Lambda functions execute without errors
- ✅ Processed data appears in curated bucket
- ✅ Schema history recorded in DynamoDB
- ✅ CloudWatch logs show activity
- ✅ No errors in any logs

---

## 📚 ADDITIONAL RESOURCES

### AWS Console URLs
- **S3:** https://s3.console.aws.amazon.com/s3/
- **Lambda:** https://console.aws.amazon.com/lambda/
- **Step Functions:** https://console.aws.amazon.com/states/
- **DynamoDB:** https://console.aws.amazon.com/dynamodb/
- **CloudWatch:** https://console.aws.amazon.com/cloudwatch/
- **Bedrock:** https://console.aws.amazon.com/bedrock/

### Documentation Files
- `README.md` - Project overview
- `BEST_PRACTICES.md` - Best practices guide
- `DEPLOYMENT_CHECKLIST.md` - Detailed checklist
- `OPTIMIZATION_SUMMARY.md` - Optimization details

### Troubleshooting
- Check CloudWatch Logs first
- Verify IAM permissions
- Confirm Bedrock access enabled
- Check AWS service quotas
- Review Terraform state

---

## 🎉 CONGRATULATIONS!

You've successfully deployed SchemaGuard AI on AWS!

**What you've accomplished:**
- ✅ Deployed 30+ AWS resources via Terraform
- ✅ Implemented event-driven serverless architecture
- ✅ Configured agentic AI with Amazon Bedrock
- ✅ Set up complete data pipeline (ingestion → processing → access)
- ✅ Implemented governance and monitoring
- ✅ Demonstrated production-grade AWS skills

**Next steps:**
- Test with more data scenarios
- Monitor costs and optimize
- Add more validation rules
- Expand agent capabilities
- Document your learnings
- Add to your portfolio

---

**Repository:** https://github.com/Rishabh1623/schemaguard-ai  
**Status:** Production Ready  
**Deployment Time:** 30-45 minutes  
**Cost:** $7-12/month (dev)

**You're now ready to showcase this in interviews!** 🎯
