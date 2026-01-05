# 🎥 Quick Reference Card - Demo Recording

## ⚡ 15-Minute Demo Flow

### 1. Introduction (2 min)
**Show:** GitHub repo, README  
**Say:** "SchemaGuard AI solves schema drift in ETL pipelines using 10+ AWS services"  
**Commands:** None

---

### 2. Architecture (3 min)
**Show:** Architecture diagram, Five Pillars  
**Say:** "Event-driven, serverless, agentic AI with governance"  
**Commands:** None

---

### 3. Code (4 min)
**Show:** Terraform files, agent code  
**Say:** "Low-code approach, centralized config, automatic packaging"  
**Files:** `terraform/locals.tf`, `terraform/data.tf`, `agents/schema_analyzer.py`

---

### 4. Deploy (5 min)
**Show:** Terminal + AWS Console  
**Commands:**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Update email
terraform init
terraform plan
terraform apply  # Type 'yes'
```
**Say:** "Zero manual steps, 30+ resources, 15 minutes"

---

### 5. Test (4 min)
**Show:** S3, Step Functions, CloudWatch  
**Commands:**
```bash
# Get bucket names
terraform output

# Upload contract
aws s3 cp contracts/contract_v1.json s3://CONTRACTS_BUCKET/

# Upload test data
aws s3 cp tests/sample-data-baseline.json s3://RAW_BUCKET/data/test.json
```
**Say:** "EventBridge triggers workflow, agent analyzes, ETL processes"

---

### 6. Schema Drift (3 min)
**Show:** Modified JSON, Step Functions execution  
**Say:** "Agent detects new field, analyzes impact, proposes contract update"  
**Commands:** Upload modified test file

---

### 7. Wrap Up (2 min)
**Show:** GitHub, documentation  
**Say:** "Production-grade, cost-optimized, secure by default"  
**Commands:** `terraform destroy` (optional)

---

## 🎯 Key Talking Points

### Problem
"Schema drift causes production failures and data corruption"

### Solution
"Proactive detection + AI analysis + governed remediation"

### Tech Stack
"10+ AWS services: S3, Lambda, Step Functions, DynamoDB, Glue, Bedrock, Athena"

### Architecture
"Event-driven, serverless, follows AWS Well-Architected Framework"

### Innovation
"True agentic AI with tools, memory, and bounded decisions"

### Business Value
"Prevents failures, reduces incident response, provides governance"

### Cost
"$7-12/month dev, 30-40% cheaper than traditional"

### Quality
"Production-grade, IaC, comprehensive docs, best practices"

---

## 📋 Pre-Recording Checklist

- [ ] OBS configured (1920x1080, 30fps)
- [ ] Terminal font size 16-18pt
- [ ] AWS CLI configured
- [ ] Bedrock access enabled
- [ ] `terraform.tfvars` ready
- [ ] Test data ready
- [ ] AWS Console tabs open
- [ ] GitHub repo open
- [ ] Script reviewed
- [ ] Test recording done

---

## 🎬 OBS Scenes

**Scene 1:** Full desktop (main)  
**Scene 2:** Code focus (VS Code)  
**Scene 3:** PIP with webcam (optional)

---

## ⚠️ Common Issues & Fixes

### Terraform Apply Fails
- Check AWS credentials: `aws sts get-caller-identity`
- Check Bedrock access
- Check IAM permissions

### Lambda Function Fails
- Check CloudWatch logs
- Verify environment variables
- Check IAM role permissions

### Step Functions Not Triggering
- Verify S3 event notifications enabled
- Check EventBridge rule
- Verify IAM role for EventBridge

---

## 🎤 Opening Script

"Hi, I'm [Name]. Today I'm demonstrating SchemaGuard AI - a production-grade, agentic AI platform I built for ETL reliability on AWS.

This solves a real business problem: schema drift in data pipelines causing production failures. Instead of detecting issues after failure, SchemaGuard AI proactively detects schema changes, analyzes impact using Amazon Bedrock, and implements governed remediation workflows.

The system uses 10+ AWS services - all deployed via Terraform infrastructure as code. Let me show you how it works."

---

## 🎤 Closing Script

"To summarize: SchemaGuard AI demonstrates production-grade AWS architecture with:
- Multi-service integration (10+ services)
- Event-driven serverless design
- Agentic AI with governance
- Cost optimization (30-40% savings)
- Security best practices
- Complete Infrastructure as Code

This project showcases the skills needed for AWS Solutions Architect roles. The complete code and documentation are on GitHub at github.com/Rishabh1623/schemaguard-ai.

Thanks for watching!"

---

## 📊 Time Markers

| Time | Section | Action |
|------|---------|--------|
| 0:00 | Intro | Show GitHub |
| 2:00 | Architecture | Show diagram |
| 5:00 | Code | Show Terraform |
| 9:00 | Deploy | Run terraform apply |
| 14:00 | Test | Upload data |
| 18:00 | Wrap | Show docs |
| 20:00 | End | GitHub repo |

---

## 💡 Pro Tips

1. **Speak slowly** - Viewers need time to process
2. **Explain WHY** - Not just what you're doing
3. **Show confidence** - You built something impressive
4. **Edit out waits** - Speed up Terraform apply
5. **Add chapters** - YouTube chapter markers
6. **Test audio** - Clear narration is critical
7. **Practice** - Run through 2-3 times before recording

---

## 🔗 Quick Links

- **Repository:** https://github.com/Rishabh1623/schemaguard-ai
- **AWS Console:** https://console.aws.amazon.com/
- **Terraform Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs

---

**Ready to record? You've got this!** 🎯
