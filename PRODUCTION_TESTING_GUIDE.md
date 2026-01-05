# 🎯 Production-Ready Testing Guide

## Complete Test Data & Execution Scenarios for SchemaGuard AI

**Purpose:** Comprehensive testing with realistic data for professional demonstrations  
**Test Files:** 8 scenarios covering all use cases  
**Duration:** 30-40 minutes for complete testing  
**Outcome:** Production-grade demonstration

---

## 📊 Test Data Overview

### Available Test Files

| File | Scenario | Purpose | Expected Result |
|------|----------|---------|-----------------|
| `01-baseline-single.json` | Single baseline event | Verify normal processing | ✅ NO_CHANGE → ETL |
| `02-baseline-batch.json` | 5 baseline events | Verify batch processing | ✅ NO_CHANGE → ETL |
| `03-additive-change.json` | New fields added | Test additive detection | ⚠️ ADDITIVE → Approval |
| `04-breaking-change.json` | Type changes | Test breaking detection | ❌ BREAKING → Quarantine |
| `05-missing-required-field.json` | Missing timestamp | Test validation | ❌ INVALID → Quarantine |
| `06-nested-structure.json` | Nested data | Test complex schema | ⚠️ ADDITIVE → Approval |
| `07-realistic-ecommerce.json` | E-commerce flow | Real-world scenario | ✅ NO_CHANGE → ETL |
| `sample-data-baseline.json` | Original baseline | Reference data | ✅ NO_CHANGE → ETL |

---

## 🚀 Quick Start Testing

### Option 1: Generate Fresh Test Data

```bash
# Navigate to tests directory
cd ~/schemaguard-ai/tests

# Run generator (creates 12+ test files)
python3 test-data-generator.py

# Expected output:
# ✅ Created: test-baseline-single.json
# ✅ Created: test-baseline-batch-10.json
# ✅ Created: test-baseline-batch-100.json
# ... (and more)
```

### Option 2: Use Pre-Created Test Files

```bash
# Test files are already in tests/ directory
cd ~/schemaguard-ai/tests
ls -la *.json

# You'll see:
# 01-baseline-single.json
# 02-baseline-batch.json
# 03-additive-change.json
# 04-breaking-change.json
# 05-missing-required-field.json
# 06-nested-structure.json
# 07-realistic-ecommerce.json
# sample-data-baseline.json
```

---

## 🎬 Complete Testing Workflow

### Phase 1: Infrastructure Verification (5 minutes)

**Step 1: Verify Deployment**
```bash
cd ~/schemaguard-ai/terraform

# Check all resources
terraform output

# Verify buckets
aws s3 ls | grep schemaguard

# Verify Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `schemaguard`)].FunctionName'

# Verify Step Functions
aws stepfunctions list-state-machines | grep schemaguard
```

**Step 2: Upload Contract**
```bash
# Get contracts bucket name
CONTRACTS_BUCKET=$(terraform output -raw contracts_bucket_name)

# Upload initial contract
aws s3 cp ../contracts/contract_v1.json s3://$CONTRACTS_BUCKET/

# Verify
aws s3 ls s3://$CONTRACTS_BUCKET/
```

---

### Phase 2: Baseline Testing (10 minutes)

**Test 1: Single Baseline Event**

```bash
# Get raw bucket name
RAW_BUCKET=$(terraform output -raw raw_bucket_name)

# Upload single baseline event
aws s3 cp ../tests/01-baseline-single.json s3://$RAW_BUCKET/data/test-01-$(date +%s).json

# Monitor Step Functions
STATE_MACHINE_ARN=$(terraform output -raw step_functions_arn)
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: Status = SUCCEEDED, change_type = NO_CHANGE
```

**Verify in AWS Console:**
1. Open Step Functions Console
2. Click on latest execution
3. Verify: Schema Analyzer → NO_CHANGE → ETL Job
4. Check CloudWatch logs for details

**Test 2: Batch Baseline Events**

```bash
# Upload batch of 5 events
aws s3 cp ../tests/02-baseline-batch.json s3://$RAW_BUCKET/data/test-02-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: All events processed successfully
```

**Test 3: E-commerce Scenario**

```bash
# Upload realistic e-commerce flow
aws s3 cp ../tests/07-realistic-ecommerce.json s3://$RAW_BUCKET/data/test-07-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: Realistic data processed successfully
```

---

### Phase 3: Schema Drift Detection (10 minutes)

**Test 4: Additive Change (New Fields)**

```bash
# Upload event with new fields
aws s3 cp ../tests/03-additive-change.json s3://$RAW_BUCKET/data/test-03-$(date +%s).json

# Monitor execution
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Get execution ARN and describe
EXECUTION_ARN="<paste-arn-here>"
aws stepfunctions describe-execution --execution-arn $EXECUTION_ARN

# Expected: change_type = ADDITIVE, routed to Contract Generator
```

**Verify in AWS Console:**
1. Step Functions: See ADDITIVE classification
2. DynamoDB: Check schema-history table for new record
3. CloudWatch: See Bedrock analysis in logs

**What to Look For:**
- ✅ New fields detected: user_location, device_type, browser
- ✅ Classification: ADDITIVE
- ✅ Risk level: LOW
- ✅ Routed to Contract Generator (approval required)

**Test 5: Nested Structure Change**

```bash
# Upload event with nested structure
aws s3 cp ../tests/06-nested-structure.json s3://$RAW_BUCKET/data/test-06-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: Nested fields detected as ADDITIVE
```

---

### Phase 4: Breaking Changes & Validation (10 minutes)

**Test 6: Breaking Change (Type Mismatch)**

```bash
# Upload event with type changes
aws s3 cp ../tests/04-breaking-change.json s3://$RAW_BUCKET/data/test-04-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: change_type = BREAKING, routed to Quarantine
```

**Verify in AWS Console:**
1. Step Functions: See BREAKING classification
2. S3 Quarantine Bucket: File moved to quarantine
3. SNS: Notification sent (check email)

**What to Look For:**
- ❌ Type changes detected:
  - timestamp: number → string
  - user_id: string → number
- ❌ Classification: BREAKING
- ❌ Risk level: HIGH
- ❌ Data quarantined (not processed)

**Test 7: Missing Required Field**

```bash
# Upload event missing required field
aws s3 cp ../tests/05-missing-required-field.json s3://$RAW_BUCKET/data/test-05-$(date +%s).json

# Monitor
aws stepfunctions list-executions --state-machine-arn $STATE_MACHINE_ARN --max-results 1

# Expected: Validation failure, quarantined
```

**Verify Quarantine:**
```bash
# Check quarantine bucket
QUARANTINE_BUCKET=$(terraform output -raw quarantine_bucket_name)
aws s3 ls s3://$QUARANTINE_BUCKET/ --recursive

# Should see quarantined files
```

---

### Phase 5: Monitoring & Audit Trail (5 minutes)

**Check Schema History**

```bash
# Query schema history table
aws dynamodb scan \
  --table-name schemaguard-ai-dev-schema-history \
  --max-items 10 \
  --output table

# Expected: Records for all schema changes detected
```

**Check CloudWatch Logs**

```bash
# View Schema Analyzer logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 1h

# View Step Functions logs
aws logs tail /aws/vendedlogs/states/schemaguard-ai-dev-orchestrator --since 1h

# Look for:
# - Schema extraction
# - Comparison results
# - Bedrock analysis
# - Classification decisions
```

**Check Curated Data**

```bash
# Check processed data in curated bucket
CURATED_BUCKET=$(terraform output -raw curated_bucket_name)
aws s3 ls s3://$CURATED_BUCKET/data/ --recursive

# Should see successfully processed files
```

---

## 🎥 Recording-Ready Test Sequence

### For Professional Demo (20 minutes)

**Sequence 1: Show Infrastructure (3 min)**
- AWS Console: Show all deployed resources
- Highlight: 6 buckets, 4 tables, 4 functions, 1 state machine

**Sequence 2: Upload Contract (2 min)**
- S3 Console: Upload contract_v1.json
- Show: Contract defines expected schema

**Sequence 3: Test Baseline (4 min)**
- Upload: 01-baseline-single.json
- Show: Step Functions execution (NO_CHANGE)
- Show: CloudWatch logs (schema matched)
- Show: Data in curated bucket

**Sequence 4: Test Additive Change (5 min)**
- Upload: 03-additive-change.json
- Show: Step Functions execution (ADDITIVE detected)
- Show: New fields identified
- Show: DynamoDB record (audit trail)
- Explain: Requires approval before processing

**Sequence 5: Test Breaking Change (4 min)**
- Upload: 04-breaking-change.json
- Show: Step Functions execution (BREAKING detected)
- Show: Data quarantined
- Show: SNS notification sent
- Explain: Safety mechanism prevents corruption

**Sequence 6: Wrap Up (2 min)**
- Show: Complete audit trail in DynamoDB
- Show: Cost optimization features
- Show: GitHub repository

---

## 📊 Expected Results Summary

### Test Results Matrix

| Test | File | Change Type | Route | Outcome |
|------|------|-------------|-------|---------|
| 1 | 01-baseline-single | NO_CHANGE | ETL | ✅ Processed |
| 2 | 02-baseline-batch | NO_CHANGE | ETL | ✅ Processed |
| 3 | 07-realistic-ecommerce | NO_CHANGE | ETL | ✅ Processed |
| 4 | 03-additive-change | ADDITIVE | Approval | ⚠️ Pending |
| 5 | 06-nested-structure | ADDITIVE | Approval | ⚠️ Pending |
| 6 | 04-breaking-change | BREAKING | Quarantine | ❌ Blocked |
| 7 | 05-missing-field | INVALID | Quarantine | ❌ Blocked |

### Success Metrics

After complete testing, you should see:

**S3 Buckets:**
- Raw: 7 uploaded files
- Curated: 3 processed files (baseline tests)
- Quarantine: 2 quarantined files (breaking/invalid)
- Contracts: 1 contract file

**DynamoDB:**
- Schema History: 7 records (one per test)
- Agent Memory: Learning from patterns
- Execution State: 7 execution records

**Step Functions:**
- 7 total executions
- 3 succeeded (baseline)
- 2 pending approval (additive)
- 2 quarantined (breaking/invalid)

**CloudWatch:**
- Logs for all Lambda invocations
- Detailed schema analysis
- Bedrock API calls
- Error handling (for invalid data)

---

## 🎯 Advanced Testing Scenarios

### Scenario 1: High Volume Testing

```bash
# Generate 100 events
cd ~/schemaguard-ai/tests
python3 test-data-generator.py

# Upload batch
aws s3 cp test-baseline-batch-100.json s3://$RAW_BUCKET/data/batch-100-$(date +%s).json

# Monitor performance
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=schemaguard-ai-dev-schema-analyzer \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum
```

### Scenario 2: Time-Series Testing

```bash
# Upload time-series data
aws s3 cp test-timeseries-24h.json s3://$RAW_BUCKET/data/timeseries-$(date +%s).json

# Analyze patterns over time
aws dynamodb query \
  --table-name schemaguard-ai-dev-schema-history \
  --index-name DataSourceIndex \
  --key-condition-expression "data_source = :source" \
  --expression-attribute-values '{":source":{"S":"raw_data"}}'
```

### Scenario 3: Mixed Workload

```bash
# Upload mixed scenarios
aws s3 cp test-mixed-batch-100.json s3://$RAW_BUCKET/data/mixed-$(date +%s).json

# Expected: Mix of NO_CHANGE, ADDITIVE, BREAKING
# Demonstrates real-world complexity
```

---

## 🔍 Troubleshooting Test Failures

### Issue: Step Functions Not Triggering

**Check:**
```bash
# Verify EventBridge rule
aws events list-rules | grep schemaguard

# Check S3 event notifications
aws s3api get-bucket-notification-configuration --bucket $RAW_BUCKET

# Verify IAM permissions
aws iam get-role --role-name schemaguard-ai-dev-eventbridge-role
```

### Issue: Lambda Function Fails

**Check:**
```bash
# View detailed logs
aws logs tail /aws/lambda/schemaguard-ai-dev-schema-analyzer --since 30m

# Check function configuration
aws lambda get-function-configuration --function-name schemaguard-ai-dev-schema-analyzer

# Verify environment variables
aws lambda get-function --function-name schemaguard-ai-dev-schema-analyzer \
  --query 'Configuration.Environment'
```

### Issue: Bedrock Access Denied

**Solution:**
1. Go to AWS Console → Bedrock
2. Click "Model access"
3. Enable "Anthropic Claude 3 Sonnet"
4. Wait for approval (usually instant)
5. Retry test

---

## 📈 Performance Benchmarks

### Expected Performance

| Metric | Target | Typical |
|--------|--------|---------|
| Schema Analysis | < 2s | 0.5-1s |
| Step Functions Execution | < 30s | 10-20s |
| End-to-End (single event) | < 1min | 30-45s |
| Batch (100 events) | < 5min | 2-3min |

### Cost Per Test

| Test Type | Lambda | Bedrock | Total |
|-----------|--------|---------|-------|
| Single Event | $0.0001 | $0.001 | $0.0011 |
| Batch (10) | $0.001 | $0.01 | $0.011 |
| Batch (100) | $0.01 | $0.10 | $0.11 |

**Daily Testing Cost:** ~$1-2 for comprehensive testing

---

## ✅ Testing Checklist

### Before Recording
- [ ] All test files generated/verified
- [ ] Infrastructure deployed successfully
- [ ] Contract uploaded
- [ ] SNS subscription confirmed
- [ ] AWS Console tabs prepared
- [ ] Test sequence planned

### During Testing
- [ ] Baseline tests pass
- [ ] Additive changes detected
- [ ] Breaking changes quarantined
- [ ] Audit trail created
- [ ] Notifications sent
- [ ] Performance acceptable

### After Testing
- [ ] All scenarios documented
- [ ] Screenshots/recordings saved
- [ ] Results analyzed
- [ ] Cleanup performed (optional)
- [ ] Lessons learned noted

---

## 🎉 Success!

You now have:
- ✅ 8+ realistic test files
- ✅ Complete testing workflow
- ✅ Production-ready scenarios
- ✅ Recording-ready sequence
- ✅ Troubleshooting guide
- ✅ Performance benchmarks

**Ready to demonstrate professional-grade AWS architecture!** 🎯

---

*Guide Version: 1.0*  
*Last Updated: December 31, 2025*  
*Project: SchemaGuard AI*
