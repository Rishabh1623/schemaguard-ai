# 🚀 SchemaGuard AI - Ubuntu AWS CLI Deployment

## 📖 Complete Guide for AWS Ubuntu Terminal

This project is optimized for deployment on **AWS Ubuntu EC2** using **AWS CLI** and **AWS Console**.

---

## 📚 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **COMPLETE_DEPLOYMENT_GUIDE.md** | Full deployment guide with all commands | Main reference - Read first! |
| **QUICK_COMMANDS.sh** | Bash script with reusable functions | Quick operations |
| **README_UBUNTU.md** | This file - Quick start | Orientation |

---

## ⚡ Quick Start (5 Minutes)

### 1. Setup Environment
```bash
# Clone or navigate to project
cd ~/schemaguard-ai

# Load quick commands
source QUICK_COMMANDS.sh

# Configure (CHANGE THE EMAIL!)
export NOTIFICATION_EMAIL="your-email@example.com"

# Verify AWS access
check_aws
```

### 2. Deploy Infrastructure
```bash
# Create all S3 buckets
create_buckets

# Configure S3 features
configure_s3

# Create DynamoDB tables
create_tables

# Create SNS topic
create_sns

# Verify deployment
list_resources
```

### 3. Test the System
```bash
# Upload test data
test_baseline

# Monitor execution
view_executions

# Check logs
view_logs
```

**That's it!** Your infrastructure is deployed.

---

## 📋 What You Get

### AWS Resources Created
- ✅ **6 S3 Buckets** - Data storage pipeline
- ✅ **4 DynamoDB Tables** - State management
- ✅ **1 SNS Topic** - Notifications
- ✅ **4 Lambda Functions** - Agent components (via Terraform)
- ✅ **1 Step Functions** - Orchestration (via Terraform)
- ✅ **1 Glue Job** - ETL processing (via Terraform)

### Total Resources: 30+

---

## 🎯 Deployment Options

### Option 1: AWS CLI Only (Manual)
Use commands from `COMPLETE_DEPLOYMENT_GUIDE.md` - Full control, step-by-step.

### Option 2: Quick Commands Script (Recommended)
```bash
source QUICK_COMMANDS.sh
create_buckets
configure_s3
create_tables
create_sns
```

### Option 3: Terraform (Automated)
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

---

## 📖 Complete Documentation

### Main Guide: COMPLETE_DEPLOYMENT_GUIDE.md

This file contains **EVERYTHING**:
- ✅ Prerequisites and setup
- ✅ All AWS CLI commands
- ✅ Terraform deployment
- ✅ Agent code and packaging
- ✅ Testing procedures
- ✅ Monitoring commands
- ✅ Troubleshooting guide
- ✅ Cleanup instructions

**Read this file for complete instructions!**

---

## 🔧 Quick Commands Reference

### Load Commands
```bash
source QUICK_COMMANDS.sh
```

### Common Operations
```bash
# Show configuration
show_config

# List all resources
list_resources

# View executions
view_executions

# View logs
view_logs

# Upload test data
test_baseline
test_additive
test_breaking

# Check costs
estimate_costs

# Show help
show_help
```

---

## 🏗️ Project Structure

```
schemaguard-ai/
├── COMPLETE_DEPLOYMENT_GUIDE.md  ← Main guide (READ THIS!)
├── QUICK_COMMANDS.sh             ← Bash functions
├── README_UBUNTU.md              ← This file
│
├── terraform/                    ← Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── glue.tf
│   ├── step-functions.tf
│   ├── sns.tf
│   └── outputs.tf
│
├── step-functions/               ← Agent workflow
│   └── schemaguard-state-machine.json
│
├── agents/                       ← Lambda functions
├── contracts/                    ← Data contracts
├── glue/                         ← ETL scripts
└── tests/                        ← Test data
```

---

## 🎓 Learning Path

### For Beginners
1. Read `COMPLETE_DEPLOYMENT_GUIDE.md` sections 1-3
2. Run commands from `QUICK_COMMANDS.sh`
3. Monitor via AWS Console

### For Experienced Users
1. Review `terraform/` directory
2. Customize variables
3. Deploy with `terraform apply`

---

## 💰 Cost Estimate

| Usage Level | Monthly Cost |
|-------------|--------------|
| Development | $5-10 |
| Testing | $20-30 |
| Production | $50-100 |

**Free Tier:** Many services have free tier coverage for first 12 months.

---

## 🔍 Monitoring

### AWS Console URLs
```bash
# Step Functions
https://console.aws.amazon.com/states/home?region=us-east-1

# Lambda
https://console.aws.amazon.com/lambda/home?region=us-east-1

# DynamoDB
https://console.aws.amazon.com/dynamodb/home?region=us-east-1

# S3
https://console.aws.amazon.com/s3/home?region=us-east-1

# CloudWatch
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1
```

### CLI Commands
```bash
# View executions
view_executions

# View logs
view_logs schemaguard-ai-dev-schema-analyzer

# Check DynamoDB
check_executions

# List S3 files
aws s3 ls s3://schemaguard-ai-dev-raw-${ACCOUNT_ID}/data/
```

---

## 🧪 Testing

### Quick Tests
```bash
# Load commands
source QUICK_COMMANDS.sh

# Test 1: Baseline (should pass)
test_baseline

# Test 2: Additive change (should trigger contract proposal)
test_additive

# Test 3: Breaking change (should quarantine)
test_breaking

# Monitor results
view_executions
```

---

## 🔧 Troubleshooting

### Common Issues

**1. AWS CLI not configured**
```bash
aws configure
# Enter your credentials
```

**2. Bedrock access denied**
```bash
# Enable via Console:
# https://console.aws.amazon.com/bedrock/home#/modelaccess
```

**3. Permission errors**
```bash
# Check IAM user permissions
aws iam get-user
```

**4. Resources already exist**
```bash
# Use unique names or delete existing resources
cleanup_all
```

---

## 🧹 Cleanup

### Delete Everything
```bash
source QUICK_COMMANDS.sh
cleanup_all
```

### Or use Terraform
```bash
cd terraform
terraform destroy -auto-approve
```

---

## ✅ Success Checklist

- [ ] AWS CLI configured
- [ ] Environment variables set
- [ ] S3 buckets created
- [ ] DynamoDB tables created
- [ ] SNS topic created and subscribed
- [ ] Test data uploaded
- [ ] Execution verified
- [ ] Logs accessible

---

## 📞 Need Help?

### 1. Check the Complete Guide
```bash
cat COMPLETE_DEPLOYMENT_GUIDE.md | less
```

### 2. View Quick Commands
```bash
source QUICK_COMMANDS.sh
show_help
```

### 3. Verify AWS Status
```bash
check_aws
list_resources
```

---

## 🎯 Next Steps

1. **Read** `COMPLETE_DEPLOYMENT_GUIDE.md` - Your main reference
2. **Load** `QUICK_COMMANDS.sh` - For quick operations
3. **Deploy** - Follow the guide step-by-step
4. **Test** - Upload sample data
5. **Monitor** - Check AWS Console and logs

---

## 🎉 You're Ready!

Everything you need is in:
- **COMPLETE_DEPLOYMENT_GUIDE.md** - Full instructions
- **QUICK_COMMANDS.sh** - Reusable commands
- **terraform/** - Infrastructure code

**Start with:** `COMPLETE_DEPLOYMENT_GUIDE.md`

---

## 📊 Project Stats

- **Total Files**: 35+
- **Terraform Resources**: 30+
- **AWS Services**: 10+
- **Deployment Time**: 30-45 minutes
- **Lines of Code**: 5,000+

---

## 🏆 What This Demonstrates

✅ Production-grade AWS architecture  
✅ Real agentic AI with Bedrock  
✅ Event-driven serverless design  
✅ Infrastructure as Code  
✅ Security best practices  
✅ Complete observability  
✅ Enterprise governance  

---

**Built for:** AWS Ubuntu EC2 + AWS CLI  
**Status:** Complete and ready to deploy  
**Documentation:** Comprehensive single-file guide  

---

*Happy Building! 🚀*
