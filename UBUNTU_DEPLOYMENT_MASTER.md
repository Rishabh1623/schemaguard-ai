# 🚀 SchemaGuard AI - Complete Ubuntu Deployment Guide

## 📋 Single File Reference for AWS Ubuntu + Terraform Deployment

**Environment:** AWS Ubuntu EC2 Server or Local Ubuntu  
**Tools:** Terraform, AWS CLI, Python  
**Time:** 30-45 minutes  
**Cost:** $0.016 for testing (4 files)  
**Difficulty:** Intermediate  

**Latest Updates:**
- ✅ 4-file demo methodology (cost-optimized)
- ✅ AWS Console testing procedures
- ✅ Production-ready deployment
- ✅ Direct Bedrock API integration

---

## 📑 Table of Contents

1. [Prerequisites & Setup](#part-1-prerequisites--setup)
2. [Clone & Prepare Project](#part-2-clone--prepare-project)
3. [Deploy Infrastructure](#part-3-deploy-infrastructure)
4. [Verify Deployment](#part-4-verify-deployment)
5. [Upload Initial Files](#part-5-upload-initial-files)
6. [Test in AWS Console](#part-6-test-in-aws-console)
7. [Test with AWS CLI](#part-7-test-with-aws-cli)
8. [Monitor & Verify](#part-8-monitor--verify)
9. [Troubleshooting](#part-9-troubleshooting)
10. [Cleanup](#part-10-cleanup)

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
# Should see: terraform/, agents/, contracts/, tests/, glue/, step-functions/, validation/
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

## ✅ PART 5: UPLOAD INITIAL FILES (2 minutes)

### Step 5.1: Upload Contract and ETL Script

```bash
# Go back to project root
cd ~/schemaguard-ai

# Get bucket names
cd terraform
export CONTRACTS_BUCKET=$(terraform output -raw contracts_bucket_name)
export SCRIPTS_BUCKET=$(terraform output -raw scripts_bucket_name)

# Upload data contract baseline
aws s3 cp ../contracts/contract_v1.json s3://$CONTRACTS_BUCKET/contract_v1.json

# Upload Glue ETL script
aws s3 cp ../glue/etl_job.py s3://$SCRIPTS_BUCKET/glue/etl_job.py

# Verify uploads
aws s3 ls s3://$CONTRACTS_BUCKET/
aws s3 ls s3://$SCRIPTS_BUCKET/glue/
```

**What this does:**
- Uploads baseline data contract (v1)
- Uploads Glue ETL job script
- Required before testing can begin

### Step 5.2: Verify Demo Test Files

```bash
# Check demo test files
cd ~/schemaguard-ai/tests/demo
ls -la

# You should see 4 test files:
# 01_baseline_perfect_match.json
# 02_additive_single_field.json
# 04_breaking_type_change_timestamp.json
# 06_invalid_missing_timestamp.json
```

**These 4 files cover all scenarios:**
- Test 1: Baseline (no changes)
- Test 2: Additive change (safe)
- Test 3: Breaking change (dangerous)
- Test 4: Invalid data (critical)

---

## ✅ PART 6: TEST IN AWS CONSOLE (Perfect for Demo Video)

**🎬 This section is designed for recording demo videos!**

### Step 6.1: Open Monitoring Tabs (Before Testing)

**Open these AWS Console tabs in your browser:**

**Tab 1: Step Functions (Main monitoring)**
```
https://console.aws.amazon.com/states/home?region=us-east-1
```
- Click on `schemaguard-ai-dev-orchestrator` state machine
- Keep "Executions" tab open
- You'll see executions appear here in real-time

**Tab 2: S3 Raw Bucket (Upload files here)**
```
https://s3.console.aws.amazon.com/s3/buckets
```
- Click on your **raw bucket** (schemaguard-ai-dev-raw-...)
- Navigate to or create folder: `data/demo/`
- Keep this tab open for uploading test files

**Tab 3: S3 Curated Bucket (Successful processing)**
```
https://s3.console.aws.amazon.com/s3/buckets
```
- Click on your **curated bucket** (schemaguard-ai-dev-curated-...)
- Navigate to `data/` folder
- Refresh to see processed files appear

**Tab 4: S3 Quarantine Bucket (Failed/risky data)**
```
https://s3.console.aws.amazon.com/s3/buckets
```
- Click on your **quarantine bucket** (schemaguard-ai-dev-quarantine-...)
- Refresh to see quarantined files

**Tab 5: DynamoDB Schema History**
```
https://console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tables
```
- Click on `schemaguard-ai-dev-schema-history` table
- Click "Explore table items"
- See schema change records appear

**Tab 6: CloudWatch Logs (Detailed logs)**
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
```
- Find `/aws/lambda/schemaguard-ai-dev-schema-analyzer`
- Click to see detailed execution logs

### Step 6.2: Test Scenario 1 - Baseline (No Changes)

**🎬 Perfect for starting your demo video!**

**1. Upload File via S3 Console:**
- Go to your **raw bucket** → `data/demo/` folder
- Click "Upload"
- Select `tests/demo/01_baseline_perfect_match.json`
- Click "Upload"

**2. Watch Processing (45 seconds):**
- Switch to **Step Functions** tab
- Click "Refresh" - new execution appears!
- Click on the execution to see visual workflow
- Watch each step turn green:
  - ✅ Schema Analyzer
  - ✅ Bedrock Impact Analysis
  - ✅ Contract Generator
  - ✅ Staging Validator
  - ✅ Production Controller

**3. Verify Results:**
- Go to **Curated bucket** → `data/` folder
- Refresh - file appears! ✅
- Go to **DynamoDB** → Schema History table
- See record: `change_type: NO_CHANGE`

**Expected Result:**
- ✅ Step Functions execution: SUCCESS
- ✅ Classification: NO_CHANGE
- ✅ File in curated bucket
- ✅ Processing time: ~45 seconds

### Step 6.3: Test Scenario 2 - Additive Change (Safe)

**🎬 Shows AI detecting safe changes!**

**1. Upload File:**
- Go to **raw bucket** → `data/demo/`
- Upload `tests/demo/02_additive_single_field.json`
- This file has a NEW field: `payment_method`

**2. Watch Step Functions:**
- New execution starts
- Schema Analyzer detects: **ADDITIVE**
- Bedrock AI analyzes: **LOW RISK**
- Contract Generator creates v2
- Staging Validator tests
- Auto-approved! ✅

**3. Verify Results:**
- **Curated bucket**: File processed successfully
- **DynamoDB**: Record shows `change_type: ADDITIVE`
- **CloudWatch Logs**: See Bedrock AI analysis

**Expected Result:**
- ✅ Classification: ADDITIVE
- ✅ Risk: LOW
- ✅ Action: Auto-approved and processed
- ✅ New contract version created

### Step 6.4: Test Scenario 3 - Breaking Change (Dangerous)

**🎬 Shows AI preventing data corruption!**

**1. Upload File:**
- Go to **raw bucket** → `data/demo/`
- Upload `tests/demo/04_breaking_type_change_timestamp.json`
- This file has `timestamp` changed from NUMBER to STRING

**2. Watch Step Functions:**
- New execution starts
- Schema Analyzer detects: **BREAKING** 🚨
- Bedrock AI analyzes: **HIGH RISK**
- Immediate quarantine decision
- No processing attempted

**3. Verify Results:**
- **Quarantine bucket**: File appears here! 🚨
- **Curated bucket**: No file (correctly blocked)
- **DynamoDB**: Record shows `change_type: BREAKING`
- **Email**: Check for SNS alert notification

**Expected Result:**
- ✅ Classification: BREAKING
- ✅ Risk: HIGH
- ✅ Action: QUARANTINED
- ✅ Alert sent to your email
- ✅ Data protected from corruption

### Step 6.5: Test Scenario 4 - Invalid Data (Critical)

**🎬 Shows data quality enforcement!**

**1. Upload File:**
- Go to **raw bucket** → `data/demo/`
- Upload `tests/demo/06_invalid_missing_timestamp.json`
- This file is MISSING required field: `timestamp`

**2. Watch Step Functions:**
- New execution starts
- Schema Analyzer detects: **INVALID** 🚨
- Immediate quarantine (no AI analysis needed)
- Critical alert triggered

**3. Verify Results:**
- **Quarantine bucket**: File quarantined immediately
- **DynamoDB**: Record shows `change_type: INVALID`
- **Email**: Urgent alert received

**Expected Result:**
- ✅ Classification: INVALID
- ✅ Action: IMMEDIATE QUARANTINE
- ✅ No processing attempted
- ✅ Urgent alert sent

### Step 6.6: View Complete Results

**After testing all scenarios, check:**

**1. S3 Buckets Summary:**
```
Raw bucket (data/demo/):        4 files uploaded
Curated bucket (data/):         2 files (baseline + additive)
Quarantine bucket:              2 files (breaking + invalid)
```

**2. DynamoDB Schema History:**
- 4 records total
- 1 NO_CHANGE
- 1 ADDITIVE
- 1 BREAKING
- 1 INVALID

**3. Step Functions Executions:**
- 4 executions total
- All completed successfully
- Visual workflow for each

**4. Cost:**
- Total: $0.016 (4 files × $0.004)
- Bedrock API: $0.012
- Other services: $0.004

---

## ✅ PART 7: TEST WITH AWS CLI (Professional Automation)

**💡 This section shows technical depth and automation skills!**

### Step 7.1: Set Environment Variables

```bash
# Go to project root
cd ~/schemaguard-ai

# Export bucket names
cd terraform
export RAW_BUCKET=$(terraform output -raw raw_bucket_name)
export CURATED_BUCKET=$(terraform output -raw curated_bucket_name)
export QUARANTINE_BUCKET=$(terraform output -raw quarantine_bucket_name)
export STATE_MACHINE_ARN=$(terraform output -raw state_machine_arn)

# Verify
echo "✅ Environment variables set:"
echo "RAW_BUCKET: $RAW_BUCKET"
echo "CURATED_BUCKET: $CURATED_BUCKET"
echo "QUARANTINE_BUCKET: $QUARANTINE_BUCKET"
```

### Step 7.2: Test All 4 Scenarios (CLI)

```bash
# Go to project root
cd ~/schemaguard-ai

# Test 1: Baseline (No Changes)
echo "📤 Test 1: Uploading baseline file..."
aws s3 cp tests/demo/01_baseline_perfect_match.json \
  s3://$RAW_BUCKET/data/demo/01_baseline_perfect_match.json
echo "⏳ Wait 60 seconds for processing..."
sleep 60

# Test 2: Additive Change (Safe)
echo "📤 Test 2: Uploading additive change file..."
aws s3 cp tests/demo/02_additive_single_field.json \
  s3://$RAW_BUCKET/data/demo/02_additive_single_field.json
echo "⏳ Wait 60 seconds..."
sleep 60

# Test 3: Breaking Change (Dangerous)
echo "📤 Test 3: Uploading breaking change file..."
aws s3 cp tests/demo/04_breaking_type_change_timestamp.json \
  s3://$RAW_BUCKET/data/demo/04_breaking_type_change_timestamp.json
echo "⏳ Wait 60 seconds..."
sleep 60

# Test 4: Invalid Data (Critical)
echo "📤 Test 4: Uploading invalid data file..."
aws s3 cp tests/demo/06_invalid_missing_timestamp.json \
  s3://$RAW_BUCKET/data/demo/06_invalid_missing_timestamp.json
echo "⏳ Wait 60 seconds..."
sleep 60

echo "✅ All 4 test files uploaded!"
```

### Step 7.3: Verify Results (CLI)

```bash
# Check curated bucket (successful processing)
echo "=== Curated Bucket (Successful) ==="
aws s3 ls s3://$CURATED_BUCKET/data/ --recursive
# Expected: 2 files (baseline + additive)

# Check quarantine bucket (failed/risky)
echo "=== Quarantine Bucket (Failed/Risky) ==="
aws s3 ls s3://$QUARANTINE_BUCKET/ --recursive
# Expected: 2 files (breaking + invalid)

# Count files
echo "=== File Count Summary ==="
echo "Curated: $(aws s3 ls s3://$CURATED_BUCKET/data/ --recursive | wc -l) files"
echo "Quarantined: $(aws s3 ls s3://$QUARANTINE_BUCKET/ --recursive | wc -l) files"
```

### Step 7.4: Check DynamoDB Records (CLI)

```bash
# Get schema history records
echo "=== Schema History Records ==="
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 10 \
  --query 'Items[*].[change_type.S, file_name.S]' \
  --output table

# Expected output:
# NO_CHANGE    | 01_baseline_perfect_match.json
# ADDITIVE     | 02_additive_single_field.json
# BREAKING     | 04_breaking_type_change_timestamp.json
# INVALID      | 06_invalid_missing_timestamp.json
```

### Step 7.5: Check Step Functions Executions (CLI)

```bash
# List recent executions
echo "=== Recent Step Functions Executions ==="
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --max-results 10 \
  --query 'executions[*].[name, status, startDate]' \
  --output table

# Expected: 4 executions, all SUCCEEDED
```

### Step 7.6: View CloudWatch Logs (CLI)

```bash
# View Schema Analyzer logs
echo "=== Schema Analyzer Logs ==="
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer \
  --since 1h \
  --format short

# View Contract Generator logs
echo "=== Contract Generator Logs ==="
aws logs tail /aws/lambda/schemaguard-ai-dev-contract-generator \
  --since 1h \
  --format short
```

---

## ✅ PART 8: MONITOR & VERIFY

### Step 8.1: AWS Console Monitoring URLs

**Open these in your browser for complete visibility:**

```bash
# Print all monitoring URLs
echo "=== AWS Console Monitoring URLs ==="
echo ""
echo "Step Functions:"
echo "https://console.aws.amazon.com/states/home?region=us-east-1"
echo ""
echo "S3 Buckets:"
echo "https://s3.console.aws.amazon.com/s3/buckets"
echo ""
echo "DynamoDB Tables:"
echo "https://console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tables"
echo ""
echo "CloudWatch Logs:"
echo "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups"
echo ""
echo "Lambda Functions:"
echo "https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions"
```

### Step 8.2: Real-Time Monitoring Tips

**For Demo Videos:**
1. Keep Step Functions tab open - shows visual workflow
2. Keep S3 curated/quarantine tabs open - see files appear
3. Refresh DynamoDB table - see records added
4. CloudWatch Logs - show detailed AI analysis

**For Troubleshooting:**
1. Check CloudWatch Logs first
2. Verify Step Functions execution details
3. Check DynamoDB for state
4. Review S3 bucket contents

### Step 8.3: Verify Processing Results

```bash
# Count files in each bucket
echo "=== Processing Results ==="
echo "Raw files: $(aws s3 ls s3://$RAW_BUCKET/data/demo/ | wc -l)"
echo "Curated files: $(aws s3 ls s3://$CURATED_BUCKET/data/ | wc -l)"
echo "Quarantined files: $(aws s3 ls s3://$QUARANTINE_BUCKET/ | wc -l)"
```

**Expected for 4 demo files:**
- Raw: 4 files
- Curated: 2 files (baseline + additive)
- Quarantined: 2 files (breaking + invalid)

### Step 8.4: Calculate Actual Cost

```bash
echo "=== Test Cost Breakdown ==="
echo "Bedrock API calls: 4 × \$0.003 = \$0.012"
echo "Lambda invocations: 16 × \$0.0000002 = \$0.0000032"
echo "Step Functions: 40 transitions × \$0.000025 = \$0.001"
echo "DynamoDB writes: 20 × \$0.00000125 = \$0.000025"
echo "S3 operations: 12 × \$0.0000004 = \$0.0000048"
echo "Total: ~\$0.016"
```

---

## ✅ PART 9: TROUBLESHOOTING

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

**Issue 4: SNS Email Not Received**
```bash
# Check SNS subscription status
aws sns list-subscriptions | grep schemaguard

# Resend confirmation email
aws sns subscribe \
  --topic-arn $(cd terraform && terraform output -raw sns_topic_arn) \
  --protocol email \
  --notification-endpoint your-email@example.com
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

### Monitor CloudWatch Logs

```bash
# Schema Analyzer
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# Contract Generator
aws logs tail /aws/lambda/schemaguard-ai-dev-contract-generator --follow

# Staging Validator
aws logs tail /aws/lambda/schemaguard-ai-dev-staging-validator --follow
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

### Upload Test Files
```bash
cd ~/schemaguard-ai
aws s3 cp tests/demo/01_baseline_perfect_match.json s3://$RAW_BUCKET/data/demo/
aws s3 cp tests/demo/02_additive_single_field.json s3://$RAW_BUCKET/data/demo/
aws s3 cp tests/demo/04_breaking_type_change_timestamp.json s3://$RAW_BUCKET/data/demo/
aws s3 cp tests/demo/06_invalid_missing_timestamp.json s3://$RAW_BUCKET/data/demo/
```

### Monitor
```bash
# Step Functions
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN

# Lambda Logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# S3 Contents
aws s3 ls s3://$RAW_BUCKET/data/demo/
aws s3 ls s3://$CURATED_BUCKET/data/
aws s3 ls s3://$QUARANTINE_BUCKET/
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

### Documentation
- `README.md` - Project overview and architecture
- `LICENSE` - MIT License

### Cost Monitoring
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

---

## 🎉 CONGRATULATIONS!

You've successfully deployed SchemaGuard AI on AWS!

**What you've accomplished:**
- ✅ Deployed 30+ AWS resources via Terraform
- ✅ Implemented event-driven serverless architecture
- ✅ Configured agentic AI with Amazon Bedrock
- ✅ Set up complete data pipeline (ingestion → processing → access)
- ✅ Implemented governance and monitoring
- ✅ Tested with 4 representative scenarios
- ✅ Demonstrated production-grade AWS skills

**Test Results:**
- Files tested: 4
- Detection accuracy: 100%
- Cost: $0.016
- Processing time: ~45 seconds per file

**Next steps:**
- Test with more data scenarios
- Monitor costs and optimize
- Document your learnings
- Showcase in interviews

---

**Repository:** https://github.com/Rishabh1623/schemaguard-ai  
**Status:** Production Ready  
**Deployment Time:** 30-45 minutes  
**Cost:** $7-12/month (dev), $0.016 per 4-file test

**You're now ready to showcase this in interviews!** 🎯
