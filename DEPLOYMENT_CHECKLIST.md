# 🚀 SchemaGuard AI - Deployment Checklist

## ✅ Pre-Deployment Checklist

### 1. AWS Prerequisites
- [ ] AWS CLI installed and configured (`aws --version`)
- [ ] AWS credentials configured (`aws sts get-caller-identity`)
- [ ] Appropriate IAM permissions for all services
- [ ] Amazon Bedrock access enabled (Claude 3 Sonnet)
- [ ] Terraform installed (`terraform --version >= 1.5`)
- [ ] Python 3.11+ installed

### 2. Project Configuration
- [ ] Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`
- [ ] Update `notification_email` in terraform.tfvars
- [ ] Review and adjust other variables as needed
- [ ] Verify AWS region is correct

### 3. Code Review
- [ ] All Terraform files present (11 files in terraform/)
- [ ] Step Functions state machine defined
- [ ] Agent code present (schema_analyzer.py minimum)
- [ ] Data contract v1 exists
- [ ] .gitignore configured

---

## 📋 Deployment Steps

### Step 1: Validate Terraform
```bash
cd terraform
terraform init
terraform validate
terraform fmt -check
```

**Expected:** ✅ All validations pass

### Step 2: Review Infrastructure Plan
```bash
terraform plan
```

**Review:**
- [ ] ~30 resources to be created
- [ ] S3 buckets (6)
- [ ] DynamoDB tables (4)
- [ ] Lambda functions (4)
- [ ] Step Functions (1)
- [ ] Glue job (1)
- [ ] SNS topic (1)
- [ ] IAM roles (4)

### Step 3: Deploy Infrastructure
```bash
terraform apply
```

**Confirm:** Type `yes` when prompted

**Expected Time:** 5-10 minutes

### Step 4: Save Outputs
```bash
terraform output > ../deployment-outputs.txt
cat ../deployment-outputs.txt
```

**Verify outputs include:**
- [ ] All bucket names
- [ ] Table names
- [ ] Lambda function names
- [ ] Step Functions ARN

### Step 5: Package Lambda Functions
```bash
cd ../agents
pip install -r requirements.txt -t package/
cd package && zip -r ../schema_analyzer.zip . && cd ..
zip -g schema_analyzer.zip schema_analyzer.py
```

**Verify:** `ls -lh schema_analyzer.zip` shows file created

### Step 6: Upload Initial Assets
```bash
# Get bucket names from terraform output
cd ../terraform
CONTRACTS_BUCKET=$(terraform output -raw contracts_bucket_name)
SCRIPTS_BUCKET=$(terraform output -raw scripts_bucket_name)

# Upload contract
aws s3 cp ../contracts/contract_v1.json s3://$CONTRACTS_BUCKET/contract_v1.json

# Verify
aws s3 ls s3://$CONTRACTS_BUCKET/
```

### Step 7: Confirm SNS Subscription
- [ ] Check email for SNS subscription confirmation
- [ ] Click "Confirm subscription" link
- [ ] Verify subscription is confirmed

### Step 8: Test Deployment
```bash
# Upload test data
RAW_BUCKET=$(terraform output -raw raw_bucket_name)
aws s3 cp ../tests/sample-data-baseline.json s3://$RAW_BUCKET/data/test-$(date +%s).json
```

### Step 9: Monitor Execution
```bash
# View Step Functions execution
STATE_MACHINE_ARN=$(terraform output -raw step_functions_arn)
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 5

# View Lambda logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --follow
```

---

## ✅ Post-Deployment Verification

### Infrastructure Verification
```bash
# Check S3 buckets
aws s3 ls | grep schemaguard

# Check DynamoDB tables
aws dynamodb list-tables | grep schemaguard

# Check Lambda functions
aws lambda list-functions | grep schemaguard

# Check Step Functions
aws stepfunctions list-state-machines | grep schemaguard
```

### Functional Verification
- [ ] Test data uploaded successfully
- [ ] Step Functions execution started
- [ ] Lambda functions invoked
- [ ] DynamoDB tables populated
- [ ] SNS notification received
- [ ] CloudWatch logs accessible

---

## 🔍 Health Checks

### 1. S3 Buckets
```bash
for bucket in raw staging curated quarantine contracts scripts; do
  echo "Checking $bucket..."
  aws s3 ls s3://schemaguard-ai-dev-$bucket-$(aws sts get-caller-identity --query Account --output text)
done
```

### 2. DynamoDB Tables
```bash
for table in schema-history contract-approvals agent-memory execution-state; do
  echo "Checking $table..."
  aws dynamodb describe-table --table-name schemaguard-ai-dev-$table --query 'Table.TableStatus'
done
```

### 3. Lambda Functions
```bash
for func in schema-analyzer contract-generator etl-patch-agent staging-validator; do
  echo "Checking $func..."
  aws lambda get-function --function-name schemaguard-ai-dev-$func --query 'Configuration.State'
done
```

---

## 🚨 Troubleshooting

### Issue: Terraform Apply Fails

**Check:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam get-user

# Verify region
aws configure get region
```

### Issue: Bedrock Access Denied

**Solution:**
1. Go to: https://console.aws.amazon.com/bedrock/
2. Click "Model access"
3. Enable "Anthropic Claude 3 Sonnet"
4. Wait for approval (usually instant)

### Issue: Lambda Function Fails

**Check:**
```bash
# View logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 1h

# Check function configuration
aws lambda get-function-configuration --function-name schemaguard-ai-dev-schema-analyzer
```

### Issue: Step Functions Not Triggering

**Check:**
```bash
# Verify EventBridge rule
aws events list-rules | grep schemaguard

# Check S3 event notifications
RAW_BUCKET=$(cd terraform && terraform output -raw raw_bucket_name)
aws s3api get-bucket-notification-configuration --bucket $RAW_BUCKET
```

---

## 💰 Cost Monitoring

### Check Current Costs
```bash
# Get cost for last 7 days
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '7 days ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=SERVICE
```

### Expected Costs
- **Development:** $5-10/month
- **Testing:** $20-30/month
- **Production:** $50-100/month

---

## 🧹 Cleanup (If Needed)

### Full Cleanup
```bash
cd terraform
terraform destroy
```

**Confirm:** Type `yes` when prompted

**Note:** This deletes ALL resources including data!

---

## 📊 Success Criteria

### Deployment Successful If:
- ✅ All Terraform resources created
- ✅ No errors in terraform apply
- ✅ All health checks pass
- ✅ Test data processed successfully
- ✅ Step Functions execution completes
- ✅ SNS notification received
- ✅ CloudWatch logs show activity

---

## 📝 Next Steps After Deployment

1. **Monitor for 24 hours** - Check CloudWatch logs and metrics
2. **Test all scenarios** - Baseline, additive, breaking changes
3. **Review costs** - Monitor AWS Cost Explorer
4. **Document learnings** - Note any issues or improvements
5. **Share project** - Update LinkedIn, resume, portfolio

---

## 🎯 Production Readiness

### Before Going to Production:
- [ ] Enable Terraform remote state (S3 backend)
- [ ] Set up CloudWatch alarms
- [ ] Configure backup policies
- [ ] Implement CI/CD pipeline
- [ ] Conduct security review
- [ ] Perform load testing
- [ ] Create runbooks
- [ ] Train operations team

---

**Status:** Ready for deployment ✅  
**Estimated Time:** 30-45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** AWS account, CLI configured, Bedrock access  

---

*Last Updated: December 31, 2025*
