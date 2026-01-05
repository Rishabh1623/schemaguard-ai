# 🎥 SchemaGuard AI - Demo Recording Guide for OBS

## 📋 Complete Guide for Recording Your AWS Project Demo

**Purpose:** Create a professional portfolio video demonstrating your AWS Solutions Architect skills  
**Duration:** 15-20 minutes  
**Tools:** OBS Studio, AWS Console, Terminal  

---

## 🎬 Pre-Recording Checklist

### 1. **OBS Setup**
- [ ] Install OBS Studio (https://obsproject.com/)
- [ ] Set resolution to 1920x1080 (Full HD)
- [ ] Set frame rate to 30 FPS
- [ ] Configure audio (microphone for narration)
- [ ] Test recording quality

### 2. **Screen Preparation**
- [ ] Close unnecessary applications
- [ ] Clear browser history/cache
- [ ] Increase terminal font size (16-18pt for readability)
- [ ] Use high-contrast terminal theme
- [ ] Prepare AWS Console in separate browser window
- [ ] Have GitHub repository open in another tab

### 3. **AWS Account Preparation**
- [ ] AWS CLI configured (`aws sts get-caller-identity`)
- [ ] Bedrock access enabled
- [ ] Clean AWS account (no conflicting resources)
- [ ] Billing alerts configured (optional)
- [ ] IAM permissions verified

### 4. **Project Preparation**
- [ ] Git repository cloned fresh
- [ ] `terraform.tfvars` configured with your email
- [ ] Test data ready (`tests/sample-data-baseline.json`)
- [ ] Contract file ready (`contracts/contract_v1.json`)
- [ ] All documentation reviewed

### 5. **Script Preparation**
- [ ] Review talking points below
- [ ] Practice narration (2-3 times)
- [ ] Prepare any notes/cheat sheet
- [ ] Time each section

---

## 🎯 Recording Structure (15-20 minutes)

### **Part 1: Introduction (2 minutes)**

#### What to Show:
- GitHub repository homepage
- README.md with badges
- Project structure in VS Code/file explorer

#### What to Say:
```
"Hi, I'm [Your Name], and today I'll demonstrate SchemaGuard AI - 
a production-grade, agentic AI platform I built for ETL reliability 
on AWS.

This project solves a real business problem: schema drift in data 
pipelines causing production failures. Instead of detecting issues 
after failure, SchemaGuard AI proactively detects schema changes, 
analyzes impact using Amazon Bedrock, and implements governed 
remediation workflows.

The system uses 10+ AWS services including S3, Lambda, Step Functions, 
DynamoDB, Glue, Bedrock, and Athena - all deployed via Terraform 
infrastructure as code.

Let me show you how it works."
```

#### Screen Actions:
1. Show GitHub repository
2. Scroll through README.md
3. Show project structure
4. Highlight key files (terraform/, agents/, docs/)

---

### **Part 2: Architecture Overview (3 minutes)**

#### What to Show:
- README.md architecture diagram
- Open `BEST_PRACTICES.md` or `PROJECT_COMPLETE.md`
- Show the Five Pillars alignment

#### What to Say:
```
"The architecture follows AWS Well-Architected Framework and 
the Five Pillars of Data Architecture:

1. Ingestion - S3 raw bucket with EventBridge triggers
2. Storage - Multiple S3 buckets for different data states
3. Processing - AWS Glue for ETL, Lambda for agents
4. Access - Athena for querying, Glue catalog for discovery
5. Governance - Data contracts, human approval gates, audit trails

The key innovation is the agentic AI component. The agent has tools, 
makes bounded decisions, maintains memory, and operates under explicit 
governance constraints. It's not just LLM automation - it's true 
agent design.

The system is event-driven: when data lands in S3, EventBridge 
triggers Step Functions, which orchestrates the entire workflow 
through multiple Lambda functions and Glue jobs."
```

#### Screen Actions:
1. Show architecture diagram
2. Highlight each component
3. Show data flow
4. Open Step Functions state machine JSON (briefly)

---

### **Part 3: Code Walkthrough (4 minutes)**

#### What to Show:
- Terraform files
- Agent code
- Key configurations

#### What to Say:
```
"Let me walk through the key components.

First, the infrastructure. Everything is defined in Terraform - 
zero manual AWS Console clicks. We have 11 Terraform files managing 
30+ AWS resources.

[Open terraform/main.tf]
Here's the main configuration. Notice we're using Terraform 1.5+ 
with AWS provider 5.0. All resources get default tags for cost 
tracking and governance.

[Open terraform/locals.tf]
This is where the low-code approach shines. Instead of repeating 
configuration across 50+ lines, we centralize it here. Change the 
Lambda runtime once, it applies everywhere. This is the DRY principle 
in action.

[Open terraform/data.tf]
Here's another low-code win. Terraform automatically packages our 
Lambda functions. No manual zip commands needed. Just write Python 
code, Terraform handles deployment.

[Open agents/schema_analyzer.py]
This is the core agent. It extracts schema from incoming JSON, 
compares against expected schema, classifies changes as additive 
or breaking, and uses Bedrock for impact analysis. Notice the 
production-grade error handling and logging.

[Open terraform/s3.tf]
For cost optimization, we have lifecycle policies on all buckets. 
Raw data moves to Intelligent Tiering after 30 days, expires after 
90. Staging data cleans up after 7 days. This saves 70-95% on 
storage costs.

[Open terraform/dynamodb.tf]
DynamoDB tables use pay-per-request billing - no capacity planning 
needed. TTL is enabled for automatic cleanup. Point-in-time recovery 
for disaster recovery."
```

#### Screen Actions:
1. Navigate through terraform/ folder
2. Show key files (main.tf, locals.tf, data.tf)
3. Open agent code (schema_analyzer.py)
4. Highlight cost optimization (lifecycle policies, TTL)
5. Show security (encryption, IAM policies)

---

### **Part 4: Deployment Demo (5-6 minutes)**

#### What to Show:
- Terminal with Terraform commands
- AWS Console showing resources being created
- Real-time deployment

#### What to Say:
```
"Now let's deploy this to AWS. Watch how simple this is.

[Open terminal]
First, I'll configure the project. I'm copying the example 
terraform.tfvars and updating my notification email.

[Run commands]
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

[Show file]
Just one variable to change - my email for SNS notifications.

[Run terraform init]
terraform init

This downloads the AWS provider and initializes the backend. 
Notice it's using local state for now - we can migrate to remote 
state later for team collaboration.

[Run terraform plan]
terraform plan

Terraform shows exactly what it will create: 6 S3 buckets, 
4 DynamoDB tables, 4 Lambda functions, 1 Step Functions state 
machine, 1 Glue job, IAM roles, CloudWatch logs, and more. 
About 30 resources total.

[Run terraform apply]
terraform apply

I'll type 'yes' to confirm.

[Switch to AWS Console while it runs]
While that's deploying, let me show you the AWS Console. 
I'll open S3, Lambda, Step Functions, and DynamoDB in separate tabs.

[Watch resources appear]
Look - buckets are being created... Lambda functions appearing... 
DynamoDB tables... This takes about 10-15 minutes for a complete 
deployment.

[Back to terminal when done]
And we're done! Terraform shows all resources created successfully. 
Zero errors, zero manual steps."
```

#### Screen Actions:
1. Open terminal (large font)
2. Run `terraform init`
3. Run `terraform plan` (scroll through output)
4. Run `terraform apply`
5. Switch to AWS Console
6. Show resources being created in real-time
7. Return to terminal for completion

---

### **Part 5: Testing the System (4 minutes)**

#### What to Show:
- Upload test data
- Monitor Step Functions execution
- Check CloudWatch logs
- Show results

#### What to Say:
```
"Now let's test the system with real data.

[Run commands]
First, I'll upload the initial data contract:

aws s3 cp contracts/contract_v1.json s3://[bucket-name]/

Now let's upload test data that matches the contract:

aws s3 cp tests/sample-data-baseline.json s3://[raw-bucket]/data/test.json

[Switch to AWS Console - Step Functions]
The moment that file hit S3, EventBridge triggered our Step Functions 
workflow. Let's watch it execute.

[Click on execution]
Here's the execution. You can see each state: Schema Analyzer runs 
first, detects no changes since this matches our contract, classifies 
it as 'NO_CHANGE', and proceeds directly to the ETL job.

[Click on Schema Analyzer step]
Here's the input and output. The agent extracted the schema, compared 
it, found no drift, and returned the analysis.

[Switch to CloudWatch Logs]
Let's check the logs. Here's the Lambda function log showing the 
schema analysis. You can see it detected the schema, compared fields, 
and determined everything matches.

[Switch to S3 - Curated bucket]
And here's the result - processed data in the curated bucket, ready 
for analytics.

[Optional: Show DynamoDB]
The schema history is stored in DynamoDB for audit trails and agent 
memory."
```

#### Screen Actions:
1. Upload contract to S3
2. Upload test data to S3
3. Open Step Functions console
4. Show execution in progress
5. Click through states
6. Open CloudWatch Logs
7. Show Lambda execution logs
8. Check S3 curated bucket for output
9. (Optional) Show DynamoDB records

---

### **Part 6: Schema Drift Scenario (3 minutes)**

#### What to Show:
- Upload data with schema changes
- Show agent detecting drift
- Show impact analysis

#### What to Say:
```
"Now let's see the real power - handling schema drift.

I'll create a test file with a new field that's not in our contract.

[Create/show modified JSON]
I've added a new field called 'user_location'. This is an additive 
change - not breaking, but needs to be tracked.

[Upload to S3]
aws s3 cp test-with-new-field.json s3://[raw-bucket]/data/

[Switch to Step Functions]
Watch the workflow. The Schema Analyzer detects the new field, 
classifies it as 'ADDITIVE', and sends it to Bedrock for impact 
analysis.

[Show execution details]
Bedrock analyzes the change and determines it's low risk. The agent 
proposes a new contract version. In a production scenario, this would 
require human approval before proceeding.

[Show CloudWatch logs]
The logs show the complete analysis: field detected, type identified, 
impact assessed, recommendation generated.

This is the governance in action - the agent detects changes, analyzes 
impact, proposes solutions, but doesn't blindly auto-deploy. Human 
approval is required for contract changes."
```

#### Screen Actions:
1. Show modified JSON file
2. Upload to S3
3. Watch Step Functions execution
4. Show schema diff in execution details
5. Show Bedrock analysis results
6. Highlight governance gates

---

### **Part 7: Cost & Monitoring (2 minutes)**

#### What to Show:
- AWS Cost Explorer (optional)
- CloudWatch dashboards
- Resource tags

#### What to Say:
```
"Let's talk about cost and monitoring.

[Show AWS Cost Explorer or mention]
This entire system costs about $7-12 per month in development, 
$80-130 in production. That's 30-40% cheaper than traditional 
approaches because we're using:
- Pay-per-request DynamoDB
- Serverless Lambda and Glue
- S3 lifecycle policies
- Automatic log retention

[Show CloudWatch]
All components have centralized logging. Every Lambda function, 
Step Functions execution, and Glue job logs to CloudWatch. 
30-day retention keeps costs down.

[Show resource tags]
Every resource is tagged for cost allocation. You can track spending 
by environment, project, or cost center.

[Show S3 lifecycle]
Lifecycle policies automatically move data to cheaper storage tiers 
and delete old data. This is set-it-and-forget-it cost optimization."
```

#### Screen Actions:
1. (Optional) Show Cost Explorer
2. Show CloudWatch Logs groups
3. Show resource tags in AWS Console
4. Show S3 lifecycle configuration

---

### **Part 8: Cleanup & Conclusion (2 minutes)**

#### What to Show:
- Terraform destroy (optional)
- GitHub repository
- Documentation

#### What to Say:
```
"To clean up all resources, it's just one command:

terraform destroy

Terraform will remove everything it created. This is the power of 
Infrastructure as Code - reproducible, version-controlled, and 
easy to tear down.

[Show GitHub]
The complete project is on GitHub with comprehensive documentation:
- 15+ documentation files
- Step-by-step deployment guides
- Best practices documentation
- Architecture explanations
- Troubleshooting guides

[Highlight key points]
What makes this project special:

1. It solves a real business problem - schema drift in ETL pipelines
2. It demonstrates true agentic AI - not just LLM usage
3. It follows AWS Well-Architected Framework
4. It's production-grade with proper governance
5. It's cost-optimized and secure by default
6. It's 100% Infrastructure as Code

This project demonstrates the skills needed for AWS Solutions 
Architect roles: multi-service integration, event-driven architecture, 
cost optimization, security best practices, and operational excellence.

[Final screen: GitHub repo]
Thanks for watching! The repository is at 
github.com/Rishabh1623/schemaguard-ai

Feel free to check it out, and let me know if you have questions!"
```

#### Screen Actions:
1. (Optional) Run `terraform destroy`
2. Show GitHub repository
3. Scroll through documentation
4. End on GitHub repo homepage

---

## 🎨 OBS Recording Tips

### Scene Setup

**Scene 1: Full Screen (Main)**
- Capture: Full desktop
- Use for: Terminal, AWS Console, VS Code

**Scene 2: Picture-in-Picture (Optional)**
- Capture: Webcam (bottom-right corner)
- Size: 20% of screen
- Use for: Introduction and conclusion

**Scene 3: Code Focus**
- Capture: VS Code window only
- Use for: Code walkthrough sections

### Audio Settings
- **Microphone:** Clear, no background noise
- **Volume:** -12 to -6 dB (not too loud)
- **Noise Suppression:** Enable in OBS
- **Test:** Record 30 seconds, play back, adjust

### Visual Settings
- **Resolution:** 1920x1080 (Full HD)
- **FPS:** 30 (smooth enough, smaller file)
- **Bitrate:** 6000-8000 Kbps (high quality)
- **Encoder:** x264 or NVENC (if you have NVIDIA GPU)

### Terminal Settings
- **Font Size:** 16-18pt (readable in video)
- **Theme:** High contrast (dark background, bright text)
- **Prompt:** Keep it simple, not too long
- **Clear screen:** Use `clear` between sections

### Browser Settings
- **Zoom:** 110-125% (easier to read)
- **Tabs:** Close unnecessary tabs
- **Bookmarks:** Hide bookmark bar
- **Extensions:** Disable or hide

---

## 📝 Narration Script Template

### Opening
```
"Hi, I'm [Name]. Today I'm demonstrating SchemaGuard AI, 
a production-grade agentic AI platform for ETL reliability 
that I built using 10+ AWS services."
```

### Problem Statement
```
"This solves a real business problem: schema drift in data 
pipelines causing production failures and data corruption."
```

### Solution Overview
```
"Instead of detecting issues after failure, SchemaGuard AI 
proactively detects schema changes, analyzes impact using 
Amazon Bedrock, and implements governed remediation workflows."
```

### Technical Highlights
```
"The system uses [Service] for [Purpose], demonstrating 
[Skill/Pattern]. This follows AWS Well-Architected Framework 
principles for [Pillar]."
```

### Closing
```
"This project demonstrates the skills needed for AWS Solutions 
Architect roles: multi-service integration, event-driven 
architecture, cost optimization, and operational excellence. 
Check out the repository at github.com/[username]/schemaguard-ai. 
Thanks for watching!"
```

---

## ⏱️ Time Management

| Section | Duration | Key Points |
|---------|----------|------------|
| Introduction | 2 min | Problem, solution, tech stack |
| Architecture | 3 min | Five pillars, event-driven, agentic AI |
| Code Walkthrough | 4 min | Terraform, agents, optimizations |
| Deployment | 5-6 min | Live deployment, AWS Console |
| Testing | 4 min | Upload data, monitor execution |
| Schema Drift | 3 min | Show agent detecting changes |
| Cost/Monitoring | 2 min | Cost optimization, logging |
| Conclusion | 2 min | Cleanup, GitHub, final thoughts |
| **Total** | **15-20 min** | Professional portfolio video |

---

## 🎯 What to Emphasize

### Technical Skills
- ✅ Multi-service AWS integration (10+ services)
- ✅ Infrastructure as Code (Terraform)
- ✅ Event-driven architecture
- ✅ Serverless design patterns
- ✅ Agentic AI implementation
- ✅ Cost optimization strategies
- ✅ Security best practices

### Business Value
- ✅ Solves real production problem
- ✅ Prevents failures before they happen
- ✅ Reduces incident response time
- ✅ Provides governed automation
- ✅ Cost-effective solution

### Professional Qualities
- ✅ Production-grade code quality
- ✅ Comprehensive documentation
- ✅ Best practices implementation
- ✅ Well-architected design
- ✅ Operational excellence

---

## 🚫 What to Avoid

### Don't:
- ❌ Apologize for mistakes (edit them out)
- ❌ Say "um" or "uh" too much (practice!)
- ❌ Go too fast (viewers need to follow)
- ❌ Skip error handling (show you know how to debug)
- ❌ Forget to explain WHY (not just WHAT)
- ❌ Make it too long (15-20 min max)
- ❌ Show sensitive info (AWS account ID is OK, but not keys)

### Do:
- ✅ Speak clearly and confidently
- ✅ Explain your decisions
- ✅ Show the business value
- ✅ Highlight best practices
- ✅ Demonstrate problem-solving
- ✅ Keep it professional
- ✅ Edit out long waits (Terraform apply)

---

## 📤 Post-Recording

### Editing (Optional)
- Cut out long waits (Terraform apply, AWS resource creation)
- Add title screen with project name
- Add section markers/chapters
- Add background music (low volume, non-distracting)
- Add captions/subtitles (accessibility)

### Publishing
- **YouTube:** Best for portfolio, searchable
- **LinkedIn:** Great for professional network
- **GitHub:** Link in README.md
- **Resume:** Add video link

### Video Description Template
```
SchemaGuard AI - Production-Grade Agentic AI Platform for ETL Reliability

In this demo, I showcase a complete AWS solution I built that solves 
schema drift in data pipelines using agentic AI and 10+ AWS services.

🔧 Technologies:
- AWS: S3, Lambda, Step Functions, DynamoDB, Glue, Bedrock, Athena, SNS
- Infrastructure as Code: Terraform
- Languages: Python, HCL
- Architecture: Event-driven, Serverless

🎯 Key Features:
- Proactive schema drift detection
- AI-powered impact analysis (Amazon Bedrock)
- Governed remediation workflows
- Production-grade security and cost optimization
- Complete Infrastructure as Code

📊 Results:
- 30+ AWS resources deployed automatically
- 30-40% cost reduction vs traditional approaches
- Zero manual deployment steps
- Production-ready from day one

🔗 Repository: https://github.com/Rishabh1623/schemaguard-ai

#AWS #CloudComputing #DataEngineering #AI #Terraform #Serverless
```

---

## ✅ Final Checklist Before Recording

### Technical
- [ ] AWS account clean and ready
- [ ] Terraform configured
- [ ] Test data prepared
- [ ] All commands tested
- [ ] AWS Console tabs open
- [ ] GitHub repository accessible

### OBS
- [ ] Recording settings configured
- [ ] Audio tested
- [ ] Screen capture working
- [ ] Font sizes readable
- [ ] Test recording done

### Presentation
- [ ] Script reviewed
- [ ] Talking points memorized
- [ ] Timing practiced
- [ ] Confident and ready

### Environment
- [ ] Quiet location
- [ ] No interruptions
- [ ] Good lighting (if using webcam)
- [ ] Water nearby (stay hydrated!)

---

## 🎬 Ready to Record!

**Remember:**
- Be confident - you built something impressive!
- Explain the "why" behind decisions
- Show business value, not just technical features
- Keep it professional but personable
- Have fun - your enthusiasm shows!

**Good luck with your recording! This will be a great addition to your portfolio.** 🎯

---

*Demo Guide Version: 1.0*  
*Last Updated: December 31, 2025*  
*Project: SchemaGuard AI*
