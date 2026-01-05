# 🚀 SchemaGuard AI - COMPLETE MASTER GUIDE

## Single File for Deploy → Test → Record

**Everything you need in ONE file**  
**Time:** 60-90 minutes total  
**Result:** Production-grade AWS project deployed, tested, and recorded

---

## 📋 TABLE OF CONTENTS

1. [Prerequisites Setup](#part-1-prerequisites-setup-10-min)
2. [Deploy Infrastructure](#part-2-deploy-infrastructure-15-min)
3. [Test with Terminal](#part-3-test-with-terminal-15-min)
4. [Test with AWS Console](#part-4-test-with-aws-console-20-min)
5. [Record Demo](#part-5-record-demo-20-min)
6. [Cleanup](#part-6-cleanup-5-min)

---

## ✅ PART 1: PREREQUISITES SETUP (10 min)

### Step 1: Launch Ubuntu EC2 (AWS Console)

1. Go to EC2 Dashboard
2. Click "Launch Instance"
3. Choose: **Ubuntu Server 22.04 LTS**
4. Instance type: **t3.medium**
5. Create/select key pair
6. Security group: Allow SSH (port 22)
7. Storage: 30 GB
8. Launch instance

### Step 2: Connect to Ubuntu

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
sudo apt update && sudo apt upgrade -y
```

### Step 3: Install Tools

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y
terraform --version
```

```bash
# Python & Git
sudo apt install python3.11 python3-pip git -y
python3.11 --version
```

### Step 4: Configure AWS

```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Format (json)
aws sts get-caller-identity
```

### Step 5: Enable Bedrock

**⚠️ IMPORTANT:** Go to AWS Console → Bedrock → Model Access → Enable "Claude 3 Sonnet"

---

## ✅ PART 2: DEPLOY INFRASTRUCTURE (15 min)

### Step 1: Clone Repository

```bash
cd ~
git clone https://github.com/Rishabh1623/schemaguard-ai.git
cd schemaguard-ai
```

### Step 2: Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Update this line:**
```
notification_email = "YOUR-EMAIL@example.com"
```

Save: `Ctrl+X`, `Y`, `Enter`

### Step 3: Deploy

```bash
terraform init
terraform plan
terraform apply
# Type: yes
```

**⏱️ Wait 10-15 minutes**

### Step 4: Save Outputs

```bash
terraform output > ../outputs.txt
cat ../outputs.txt
```

### Step 5: Upload Initial Files

```bash
cd ..

# Get bucket names
CONTRACTS_BUCKET=$(cd terraform && terraform output -raw contracts_bucket_name)
RAW_BUCKET=$(cd terraform && terraform output -raw raw_bucket_name)
SCRIPTS_BUCKET=$(cd terraform && terraform output -raw scripts_bucket_name)

# Upload contract
aws s3 cp contracts/contract_v1.json s3://$CONTRACTS_BUCKET/

# Upload Glue script
aws s3 cp glue/etl_job.py s3://$SCRIPTS_BUCKET/glue/

# Verify
aws s3 ls s3://$CONTRACTS_BUCKET/
```

### Step 6: Confirm SNS

**Check your email** → Click "Confirm subscription"

---

## ✅ PART 3: TEST WITH TERMINAL (15 min)

### Test 1: Baseline Data (Should Process ✅)

```bash
# Upload baseline test
aws s3 cp tests/01-baseline-single.json s3://$RAW_BUCKET/data/test-01-$(date +%s).json

# Monitor Step Functions
STATE_MACHINE_ARN=$(cd terraform && terraform output -raw step_functions_arn)
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Check logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 5m

# Expected: change_type = NO_CHANGE, Status = SUCCEEDED
```

### Test 2: Additive Change (Should Detect ⚠️)

```bash
# Upload file with new fields
aws s3 cp tests/03-additive-change.json s3://$RAW_BUCKET/data/test-03-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Check DynamoDB for schema history
aws dynamodb scan --table-name schemaguard-ai-dev-schema-history --max-items 1

# Expected: change_type = ADDITIVE, new fields detected
```

### Test 3: Breaking Change (Should Quarantine ❌)

```bash
# Upload file with type changes
aws s3 cp tests/04-breaking-change.json s3://$RAW_BUCKET/data/test-04-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Check quarantine bucket
QUARANTINE_BUCKET=$(cd terraform && terraform output -raw quarantine_bucket_name)
aws s3 ls s3://$QUARANTINE_BUCKET/ --recursive

# Expected: change_type = BREAKING, file quarantined
```

### Verify Results

```bash
# Check curated bucket (processed data)
CURATED_BUCKET=$(cd terraform && terraform output -raw curated_bucket_name)
aws s3 ls s3://$CURATED_BUCKET/data/ --recursive

# Check all executions
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 10
```

---

## ✅ PART 4: TEST WITH AWS CONSOLE (20 min)

### Setup Browser

**Open these AWS Console tabs:**

1. **S3:** https://s3.console.aws.amazon.com/s3/buckets
2. **Lambda:** https://console.aws.amazon.com/lambda/home#/functions
3. **Step Functions:** https://console.aws.amazon.com/states/home#/statemachines
4. **DynamoDB:** https://console.aws.amazon.com/dynamodbv2/home#tables
5. **CloudWatch:** https://console.aws.amazon.com/cloudwatch/home#logsV2:log-groups

**Browser settings:**
- Zoom: 125%
- Hide bookmarks (Ctrl+Shift+B)
- Full screen (F11)

### Console Test 1: Infrastructure Overview

**S3 Console:**
- Filter: "schemaguard"
- Should see: 6 buckets (raw, staging, curated, quarantine, contracts, scripts)

**Lambda Console:**
- Filter: "schemaguard"
- Should see: 4 functions (schema-analyzer, contract-generator, etl-patch-agent, staging-validator)

**Step Functions Console:**
- Filter: "schemaguard"
- Should see: 1 state machine (orchestrator)

**DynamoDB Console:**
- Filter: "schemaguard"
- Should see: 4 tables (schema-history, contract-approvals, agent-memory, execution-state)

### Console Test 2: Upload & Monitor

**In S3 Console:**
1. Navigate to raw bucket
2. Go to `data/` folder
3. Click "Upload"
4. Select `tests/02-baseline-batch.json`
5. Click "Upload"

**In Step Functions Console:**
1. Refresh page
2. Click on latest execution
3. Watch visual workflow
4. Click on "Schema Analyzer" state
5. View Input/Output tabs
6. See: change_type = NO_CHANGE

**In CloudWatch Console:**
1. Find `/aws/lambda/schemaguard-ai-dev-schema-analyzer`
2. Click on latest log stream
3. See detailed analysis logs

### Console Test 3: Schema Drift Detection

**In S3 Console:**
1. Upload `tests/03-additive-change.json` to raw bucket data/ folder

**In Step Functions Console:**
1. Watch new execution start
2. Click on execution
3. See "Schema Analyzer" detect ADDITIVE change
4. See workflow route to "Contract Generator"

**In DynamoDB Console:**
1. Open `schema-history` table
2. Click "Explore table items"
3. See record with:
   - added_fields: user_location, device_type, browser
   - change_type: ADDITIVE

### Console Test 4: Breaking Change

**In S3 Console:**
1. Upload `tests/04-breaking-change.json`

**In Step Functions Console:**
1. Watch execution
2. See BREAKING classification
3. See route to Quarantine

**In S3 Console:**
1. Navigate to quarantine bucket
2. See quarantined file

---

## ✅ PART 5: RECORD DEMO (20 min)

### OBS Setup

**Settings:**
- Resolution: 1920x1080
- FPS: 30
- Bitrate: 6000-8000 Kbps
- Audio: Clear microphone

**Scenes:**
- Scene 1: Full browser (AWS Console)
- Scene 2: Terminal
- Scene 3: Split screen (both)

### Recording Script

**Scene 1: Introduction (2 min)**

*Show GitHub repository*

"Hi, I'm [Name]. Today I'm demonstrating SchemaGuard AI - a production-grade agentic AI platform for ETL reliability on AWS. This solves schema drift in data pipelines using 10+ AWS services."

**Scene 2: Infrastructure (3 min)**

*Show AWS Console - all resources*

"Here's the deployed infrastructure: 6 S3 buckets, 4 Lambda functions, 1 Step Functions state machine, 4 DynamoDB tables. All deployed with a single Terraform command."

**Scene 3: Test Baseline (4 min)**

*Upload test file in S3 Console*

"Let's test with data matching our contract. EventBridge triggered the workflow. Schema Analyzer completed successfully. Change type: NO_CHANGE."

**Scene 4: Test Schema Drift (5 min)**

*Upload additive change file*

"Now let's test schema drift. Agent detected the change! Classification: ADDITIVE. New fields detected. Complete audit trail stored."

**Scene 5: Test Breaking Change (3 min)**

*Upload breaking change file*

"Let's test a breaking change. Detected: BREAKING. Data quarantined. Won't corrupt production."

**Scene 6: Wrap Up (3 min)**

"SchemaGuard AI demonstrates event-driven serverless architecture, agentic AI with governance, and production-grade observability. Complete code at github.com/Rishabh1623/schemaguard-ai"

---

## ✅ PART 6: CLEANUP (5 min)

### Option A: Destroy Everything

```bash
cd ~/schemaguard-ai/terraform
terraform destroy
# Type: yes
```

### Option B: Keep Infrastructure, Clean Data

```bash
# Empty buckets
aws s3 rm s3://$RAW_BUCKET --recursive
aws s3 rm s3://$CURATED_BUCKET --recursive
aws s3 rm s3://$QUARANTINE_BUCKET --recursive
```

---

## 📊 QUICK REFERENCE

### Essential Commands

```bash
# Deploy
cd ~/schemaguard-ai/terraform
terraform apply

# Upload test
aws s3 cp tests/01-baseline-single.json s3://$RAW_BUCKET/data/

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN

# Logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow

# Cleanup
terraform destroy
```

### Test Files

| File | Scenario | Expected Result |
|------|----------|-----------------|
| `01-baseline-single.json` | Normal data | ✅ Processed |
| `02-baseline-batch.json` | Batch (5 events) | ✅ Processed |
| `03-additive-change.json` | New fields | ⚠️ Approval needed |
| `04-breaking-change.json` | Type changes | ❌ Quarantined |
| `05-missing-required-field.json` | Missing field | ❌ Quarantined |
| `06-nested-structure.json` | Nested data | ⚠️ Approval needed |
| `07-realistic-ecommerce.json` | E-commerce | ✅ Processed |

### AWS Console URLs

- **S3:** https://s3.console.aws.amazon.com/s3/
- **Lambda:** https://console.aws.amazon.com/lambda/
- **Step Functions:** https://console.aws.amazon.com/states/
- **DynamoDB:** https://console.aws.amazon.com/dynamodb/
- **CloudWatch:** https://console.aws.amazon.com/cloudwatch/

---

## 🎯 SUCCESS CHECKLIST

### Deployment Success
- [ ] All 30+ resources created
- [ ] No Terraform errors
- [ ] SNS subscription confirmed
- [ ] Contract uploaded
- [ ] Glue script uploaded

### Testing Success
- [ ] Baseline test processed
- [ ] Additive change detected
- [ ] Breaking change quarantined
- [ ] Audit trail in DynamoDB
- [ ] CloudWatch logs visible

### Recording Success
- [ ] Clear audio
- [ ] Readable screen (125% zoom)
- [ ] All scenarios shown
- [ ] Business value explained
- [ ] Professional presentation

---

## 🚨 TROUBLESHOOTING

### Issue: Terraform Apply Fails
```bash
aws sts get-caller-identity
aws configure get region
```

### Issue: Bedrock Access Denied
**Solution:** AWS Console → Bedrock → Model Access → Enable Claude 3 Sonnet

### Issue: Lambda Function Fails
```bash
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 1h
```

### Issue: Step Functions Not Triggering
```bash
aws events list-rules | grep schemaguard
aws s3api get-bucket-notification-configuration --bucket $RAW_BUCKET
```

---

## 💰 COST ESTIMATE

**Development:** $7-12/month  
**Production:** $80-130/month

---

## 🎉 YOU'RE DONE!

You've successfully:
- ✅ Deployed 30+ AWS resources
- ✅ Tested all scenarios
- ✅ Recorded professional demo
- ✅ Demonstrated AWS expertise

**Repository:** https://github.com/Rishabh1623/schemaguard-ai

**This is your AWS Solutions Architect portfolio project!** 🎯
