# 🚀 SchemaGuard AI - Complete Ubuntu Deployment Guide

## 📋 Single File Reference for AWS Ubuntu + Terraform Deployment

**Environment:** AWS Ubuntu EC2 Server or Local Ubuntu  
**Tools:** Terraform, AWS CLI, Python  
**Time:** 30-45 minutes  
**Cost:** $0.04 for testing (10 files)  
**Difficulty:** Intermediate  

**Latest Updates:**
- ✅ 10-file testing methodology (cost-optimized)
- ✅ AWS Console testing procedures
- ✅ Quick demo scripts included
- ✅ Direct Bedrock API integration

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

## ✅ PART 5: PREPARE TEST DATA (2 minutes)

### Step 5.1: Generate Demo Files

```bash
# Go back to project root
cd ~/schemaguard-ai

# Generate 10 demo files (all scenarios covered)
python3 tests/quick-demo.py
```

**What this creates:**
- 10 test files in `tests/demo/` directory
- Covers all 5 scenarios:
  - 1 baseline (no changes)
  - 4 additive (new fields)
  - 2 breaking (type changes)
  - 2 invalid (missing fields)
  - 1 nested structure

**Cost:** $0.04 for processing all 10 files

### Step 5.2: Save Bucket Names for Reference

```bash
# Get bucket names from Terraform output
cd ~/schemaguard-ai/terraform

echo "=== Save These Bucket Names ==="
echo ""
echo "CONTRACTS_BUCKET: $(terraform output -raw contracts_bucket_name)"
echo "RAW_BUCKET: $(terraform output -raw raw_bucket_name)"
echo "STAGING_BUCKET: $(terraform output -raw staging_bucket_name)"
echo "CURATED_BUCKET: $(terraform output -raw curated_bucket_name)"
echo "QUARANTINE_BUCKET: $(terraform output -raw quarantine_bucket_name)"
echo "SCRIPTS_BUCKET: $(terraform output -raw scripts_bucket_name)"
echo ""
echo "Copy these names - you'll need them for AWS Console testing"
```

---

## ✅ PART 6: TEST IN AWS CONSOLE (Perfect for Demo Video)

**🎬 This section is designed for recording demo videos!**

### Step 6.1: Upload Initial Files via AWS Console

**1. Open S3 Console:**
```
https://s3.console.aws.amazon.com/s3/buckets
```

**2. Upload Data Contract:**
- Click on your **contracts bucket** (schemaguard-ai-dev-contracts-...)
- Click "Upload"
- Click "Add files"
- Select `contracts/contract_v1.json` from your local machine
- Click "Upload"
- ✅ Verify file appears in bucket

**3. Upload Glue Script:**
- Click on your **scripts bucket** (schemaguard-ai-dev-scripts-...)
- Click "Create folder" → Name it `glue` → Create
- Click on `glue/` folder
- Click "Upload"
- Select `glue/etl_job.py` from your local machine
- Click "Upload"
- ✅ Verify file appears in glue/ folder

### Step 6.2: Open Monitoring Tabs (Before Testing)

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

### Step 6.3: Test Scenario 1 - Baseline (No Changes)

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

### Step 6.4: Test Scenario 2 - Additive Change (Safe)

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

### Step 6.5: Test Scenario 3 - Breaking Change (Dangerous)

**🎬 Shows AI preventing data corruption!**

**1. Upload File:**
- Go to **raw bucket** → `data/demo/`
- Upload `tests/demo/04_breaking_type_change_timestamp.json`
- This file has `timestamp` changed from STRING to NUMBER

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

### Step 6.6: Test Scenario 4 - Invalid Data (Critical)

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

### Step 6.7: View Complete Results

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
export CONTRACTS_BUCKET=$(cd terraform && terraform output -raw contracts_bucket_name)
export RAW_BUCKET=$(cd terraform && terraform output -raw raw_bucket_name)
export STAGING_BUCKET=$(cd terraform && terraform output -raw staging_bucket_name)
export CURATED_BUCKET=$(cd terraform && terraform output -raw curated_bucket_name)
export QUARANTINE_BUCKET=$(cd terraform && terraform output -raw quarantine_bucket_name)
export SCRIPTS_BUCKET=$(cd terraform && terraform output -raw scripts_bucket_name)

# Verify
echo "✅ Environment variables set:"
echo "RAW_BUCKET: $RAW_BUCKET"
echo "CURATED_BUCKET: $CURATED_BUCKET"
echo "QUARANTINE_BUCKET: $QUARANTINE_BUCKET"
```

### Step 7.2: Upload Initial Data (CLI)

```bash
# Upload data contract
aws s3 cp contracts/contract_v1.json s3://$CONTRACTS_BUCKET/contract_v1.json

# Upload Glue script
aws s3 cp glue/etl_job.py s3://$SCRIPTS_BUCKET/glue/etl_job.py

# Verify uploads
echo "=== Verifying Uploads ==="
aws s3 ls s3://$CONTRACTS_BUCKET/
aws s3 ls s3://$SCRIPTS_BUCKET/glue/
```

### Step 7.3: Test All Scenarios (CLI)

```bash
# Test 1: Baseline (No Changes)
echo "📤 Uploading baseline file..."
aws s3 cp tests/demo/01_baseline_perfect_match.json \
  s3://$RAW_BUCKET/data/demo/01_baseline_perfect_match.json
echo "⏳ Wait 45 seconds for processing..."
sleep 45

# Test 2: Additive Change (Safe)
echo "📤 Uploading additive change file..."
aws s3 cp tests/demo/02_additive_single_field.json \
  s3://$RAW_BUCKET/data/demo/02_additive_single_field.json
echo "⏳ Wait 45 seconds..."
sleep 45

# Test 3: Breaking Change (Dangerous)
echo "📤 Uploading breaking change file..."
aws s3 cp tests/demo/04_breaking_type_change_timestamp.json \
  s3://$RAW_BUCKET/data/demo/04_breaking_type_change_timestamp.json
echo "⏳ Wait 45 seconds..."
sleep 45

# Test 4: Invalid Data (Critical)
echo "📤 Uploading invalid data file..."
aws s3 cp tests/demo/06_invalid_missing_timestamp.json \
  s3://$RAW_BUCKET/data/demo/06_invalid_missing_timestamp.json
echo "⏳ Wait 45 seconds..."
sleep 45

echo "✅ All test files uploaded!"
```

### Step 7.4: Verify Results (CLI)

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

### Step 7.5: Check DynamoDB Records (CLI)

```bash
# Get schema history records
echo "=== Schema History Records ==="
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 10 \
  --query 'Items[*].[change_type.S, file_name.S, timestamp.N]' \
  --output table

# Expected output:
# NO_CHANGE    | 01_baseline_perfect_match.json
# ADDITIVE     | 02_additive_single_field.json
# BREAKING     | 04_breaking_type_change_timestamp.json
# INVALID      | 06_invalid_missing_timestamp.json
```

### Step 7.6: Check Step Functions Executions (CLI)

```bash
# Get state machine ARN
STATE_MACHINE_ARN=$(cd terraform && terraform output -raw state_machine_arn)

# List recent executions
echo "=== Recent Step Functions Executions ==="
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN \
  --max-results 10 \
  --query 'executions[*].[name, status, startDate]' \
  --output table

# Expected: 4 executions, all SUCCEEDED
```

### Step 7.7: View CloudWatch Logs (CLI)

```bash
# View Schema Analyzer logs (last 50 lines)
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

### Step 7.8: Batch Upload All Demo Files (CLI)

```bash
# Upload all 10 demo files at once
echo "📤 Uploading all 10 demo files..."
cd ~/schemaguard-ai/tests/demo

for file in *.json; do
  echo "Uploading: $file"
  aws s3 cp "$file" s3://$RAW_BUCKET/data/demo/
  sleep 5  # Wait between uploads to avoid overwhelming
done

echo "✅ All 10 files uploaded!"
echo "⏳ Wait 8-10 minutes for all processing to complete..."
echo ""
echo "Monitor at: https://console.aws.amazon.com/states/"
```

---

## ✅ PART 8: MONITOR IN AWS CONSOLE

### Step 7.1: Step Functions Console

```bash
# Open Step Functions in browser
echo "Step Functions Console:"
echo "https://console.aws.amazon.com/states/home?region=$(aws configure get region)"
```

**What to check:**
1. Click on `schemaguard-ai-dev-orchestrator` state machine
2. View "Executions" tab
3. Click on latest execution
4. See visual workflow progress
5. Check each step's input/output

### Step 7.2: CloudWatch Logs

```bash
# View Schema Analyzer logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# Press Ctrl+C to stop
```

**Or in Console:**
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
```

### Step 7.3: DynamoDB Tables

```bash
# Check schema history
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 5
```

**Or in Console:**
```
https://console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tables
```

**What to check:**
- `schema-history` - All detected changes
- `contract-approvals` - Pending approvals
- `agent-memory` - Historical patterns
- `execution-state` - Workflow states

### Step 7.4: S3 Buckets

```bash
# Check curated bucket (successful processing)
CURATED_BUCKET=$(cd ~/schemaguard-ai/terraform && terraform output -raw curated_bucket_name)
aws s3 ls s3://$CURATED_BUCKET/data/ --recursive

# Check quarantine bucket (failed/risky data)
QUARANTINE_BUCKET=$(cd ~/schemaguard-ai/terraform && terraform output -raw quarantine_bucket_name)
aws s3 ls s3://$QUARANTINE_BUCKET/ --recursive
```

**Or in Console:**
```
https://s3.console.aws.amazon.com/s3/buckets
```

### Step 7.5: SNS Notifications

**Check your email for:**
- Subscription confirmation (first time)
- Schema drift alerts (breaking changes)
- Quarantine notifications (invalid data)

---

## ✅ PART 8: VERIFY RESULTS

### Step 8.1: Check Processing Results

```bash
# Count files in each bucket
echo "=== Processing Results ==="
echo "Raw files: $(aws s3 ls s3://$RAW_BUCKET/data/demo/ | wc -l)"
echo "Curated files: $(aws s3 ls s3://$CURATED_BUCKET/data/ | wc -l)"
echo "Quarantined files: $(aws s3 ls s3://$QUARANTINE_BUCKET/ | wc -l)"
```

**Expected for 10 demo files:**
- Raw: 10 files
- Curated: 7 files (baseline + additive + nested)
- Quarantined: 3 files (2 breaking + 1 invalid)

### Step 8.2: Verify Schema Detection

```bash
# Get latest schema analysis
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 10 \
  --query 'Items[*].[change_type.S, timestamp.N]' \
  --output table
```

**Expected change types:**
- NO_CHANGE: 1
- ADDITIVE: 5
- BREAKING: 2
- INVALID: 2

### Step 8.3: Calculate Actual Cost

```bash
echo "=== Test Cost Breakdown ==="
echo "Bedrock API calls: 10 × \$0.003 = \$0.03"
echo "Lambda invocations: 40 × \$0.0000002 = \$0.000008"
echo "Step Functions: 100 transitions × \$0.000025 = \$0.0025"
echo "DynamoDB writes: 50 × \$0.00000125 = \$0.0000625"
echo "S3 operations: 30 × \$0.0000004 = \$0.000012"
echo "Total: ~\$0.04"
```

---

## ✅ PART 8: MONITOR IN AWS CONSOLE

### Monitoring Dashboard URLs

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

### Real-Time Monitoring Tips

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

---

## ✅ PART 9: VERIFY RESULTS

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
- ✅ Tested with 10 representative scenarios
- ✅ Demonstrated production-grade AWS skills

**Test Results:**
- Files tested: 10
- Detection accuracy: 100%
- Cost: $0.04
- Processing time: ~45 seconds per file

**Next steps:**
- Test with more data scenarios
- Monitor costs and optimize
- Explore Bedrock AgentCore integration
- Document your learnings

---

**Repository:** https://github.com/Rishabh1623/schemaguard-ai  
**Status:** Production Ready  
**Deployment Time:** 30-45 minutes  
**Cost:** $7-12/month (dev)

**You're now ready to showcase this in interviews!** 🎯
