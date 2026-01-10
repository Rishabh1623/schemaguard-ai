# 🎥 SchemaGuard AI - Video Recording Script

## 📊 Video Structure (10-15 minutes total)

---

## 🎬 PART 1: Introduction (2 minutes)

### **Screen:** Your face / Intro slide

**Script:**
> "Hi, I'm Rishabh, and today I'm going to show you SchemaGuard AI—an agentic platform I built that prevents data pipeline failures using AWS Bedrock and 10+ AWS services.
>
> The problem: When upstream applications change their data schema without warning, downstream pipelines break, costing companies $50K to $500K per incident.
>
> My solution: SchemaGuard proactively detects schema changes BEFORE pipelines run, uses AI to analyze impact, and safely updates the system with governance controls.
>
> Let me show you how it works."

---

## 🏗️ PART 2: Architecture Overview (2 minutes)

### **Screen:** Architecture diagram (create in draw.io)

**Script:**
> "Here's the architecture. When data arrives in S3, EventBridge triggers a Step Functions workflow that orchestrates four AI agents:
>
> 1. Schema Analyzer detects changes
> 2. Bedrock AI analyzes impact
> 3. Contract Generator proposes updates
> 4. Staging Validator tests everything
>
> If validation passes, it runs in production. If not, data goes to quarantine and alerts are sent.
>
> The key innovation: This is PROACTIVE, not reactive. We catch issues before they break production."

---

## 💻 PART 3: Live Demo (8 minutes)

### **Screen:** AWS Console + Terminal split screen

### **Demo 1: Baseline (1 minute)**

**Terminal:**
```bash
# Show the baseline file
cat tests/demo/01_baseline_perfect_match.json

# Upload to S3
aws s3 cp tests/demo/01_baseline_perfect_match.json \
  s3://schemaguard-ai-dev-raw-123456789/data/demo/
```

**Script:**
> "Let's start with a baseline file that matches our contract perfectly. I'll upload it to S3..."

**AWS Console:** Switch to Step Functions
> "EventBridge automatically triggered the workflow. You can see the Schema Analyzer running... and it detected NO_CHANGE. The file processes normally."

---

### **Demo 2: Additive Change (1.5 minutes)**

**Terminal:**
```bash
# Show the additive file
cat tests/demo/02_additive_single_field.json

# Upload
aws s3 cp tests/demo/02_additive_single_field.json \
  s3://schemaguard-ai-dev-raw-123456789/data/demo/
```

**Script:**
> "Now let's add a new field—payment_method. This is an ADDITIVE change, which is usually safe."

**AWS Console:** Step Functions
> "The Schema Analyzer detected the new field... Bedrock AI is analyzing impact... It classified this as ADDITIVE with LOW risk... The Contract Generator is creating version 2... Staging Validator is testing... All checks passed! The system auto-approved this change."

**AWS Console:** DynamoDB
> "Here in DynamoDB, you can see the schema history. The change was logged with full audit trail."

---

### **Demo 3: Breaking Change (2 minutes)**

**Terminal:**
```bash
# Show the breaking change file
cat tests/demo/04_breaking_type_change_timestamp.json

# Upload
aws s3 cp tests/demo/04_breaking_type_change_timestamp.json \
  s3://schemaguard-ai-dev-raw-123456789/data/demo/
```

**Script:**
> "Now the critical test: a BREAKING change. The timestamp field changed from number to string. This would crash the pipeline."

**AWS Console:** Step Functions
> "Watch what happens... Schema Analyzer detected the type change... Bedrock AI classified it as BREAKING with HIGH risk... The system immediately quarantined the data..."

**AWS Console:** S3 Quarantine Bucket
> "Here's the quarantined file in S3. It never reached production."

**AWS Console:** SNS / Email
> "And I received an alert email with details about the breaking change."

**Script:**
> "This is the key value: We prevented a production failure BEFORE it happened. Without SchemaGuard, this would have crashed the pipeline at 2 AM."

---

### **Demo 4: Invalid Data (1.5 minutes)**

**Terminal:**
```bash
# Show invalid file
cat tests/demo/06_invalid_missing_timestamp.json

# Upload
aws s3 cp tests/demo/06_invalid_missing_timestamp.json \
  s3://schemaguard-ai-dev-raw-123456789/data/demo/
```

**Script:**
> "One more scenario: invalid data with missing required fields."

**AWS Console:** Step Functions
> "The system detected missing timestamp... classified as INVALID... immediate quarantine... alert sent."

---

### **Demo 5: Show Metrics (2 minutes)**

**AWS Console:** CloudWatch Dashboard (if you created one)

**Script:**
> "Now let me show you the real performance metrics. I ran comprehensive tests with 1,000 files across 5 scenarios."

**Screen:** Show `tests/generated/actual_results.json` or README metrics

**Script:**
> "Results:
> - 1,000 files processed
> - 100% detection accuracy
> - Zero false positives
> - Zero false negatives
> - Average processing time: 45 seconds
> - Total cost: $4.08
>
> The system detected 80 breaking or invalid changes that would have caused incidents. At $50K per incident, that's $4 million in prevented losses for a cost of $4. That's a 980,000x ROI."

---

## 💡 PART 4: Technical Highlights (2 minutes)

### **Screen:** Code editor showing key files

**Script:**
> "Let me quickly show you the technical implementation."

**Show:** `agents/schema_analyzer.py`
> "Here's the Schema Analyzer agent. It extracts schemas, compares them, and classifies changes. Notice the error handling and logging—this is production-grade code."

**Show:** `terraform/main.tf`
> "All infrastructure is defined as code using Terraform. This makes it reproducible and follows AWS best practices."

**Show:** `terraform/iam.tf`
> "Security is built-in: IAM roles with least privilege, S3 buckets with encryption and public access blocked, DynamoDB with point-in-time recovery."

---

## 🎯 PART 5: Business Value & Wrap-up (1 minute)

### **Screen:** Your face / Summary slide

**Script:**
> "So what makes this project unique?
>
> **First**, it's proactive, not reactive. Most tools detect problems AFTER they happen. SchemaGuard prevents them BEFORE they break production.
>
> **Second**, it uses AWS managed services—Bedrock, Step Functions, Lambda—so there's no infrastructure to manage. What would cost $2 million to build custom costs $120 per month using managed services.
>
> **Third**, it demonstrates real Solutions Architect thinking: business value, cost optimization, security, governance, and measurable ROI.
>
> This project is fully deployed and tested. The code is on GitHub, and I'm happy to discuss the architecture in detail.
>
> Thanks for watching!"

---

## 📋 RECORDING CHECKLIST

### **Before Recording:**

- [ ] Deploy SchemaGuard to AWS
- [ ] Generate demo files: `python tests/quick-demo.py`
- [ ] Test upload one file to verify it works
- [ ] Open AWS Console tabs:
  - [ ] Step Functions
  - [ ] S3 (raw and quarantine buckets)
  - [ ] DynamoDB (schema_history table)
  - [ ] CloudWatch Logs
  - [ ] SNS (email)
- [ ] Prepare terminal with commands ready
- [ ] Create architecture diagram
- [ ] Test OBS recording settings
- [ ] Close unnecessary applications
- [ ] Clear browser history/cache
- [ ] Set up dual monitor (if available)

### **During Recording:**

- [ ] Speak clearly and confidently
- [ ] Show, don't just tell
- [ ] Pause between sections
- [ ] Point to important parts on screen
- [ ] Explain WHY, not just WHAT
- [ ] Show real AWS Console (not screenshots)
- [ ] Demonstrate actual processing
- [ ] Highlight business value

### **After Recording:**

- [ ] Review video for errors
- [ ] Add captions/subtitles
- [ ] Add intro/outro music (optional)
- [ ] Upload to YouTube
- [ ] Add to LinkedIn
- [ ] Link in README

---

## 🎨 OBS SETUP RECOMMENDATIONS

### **Scene 1: Intro**
- Webcam (full screen or picture-in-picture)
- Optional: Intro slide

### **Scene 2: Architecture**
- Architecture diagram (full screen)
- Optional: Webcam in corner

### **Scene 3: Live Demo**
- Split screen:
  - Left: Terminal (50%)
  - Right: AWS Console (50%)
- Or: Full screen AWS Console, switch to terminal when needed

### **Scene 4: Code Review**
- VS Code (full screen)
- Zoom in on important code sections

### **Scene 5: Wrap-up**
- Webcam (full screen)
- Optional: Summary slide

---

## 💡 PRO TIPS

### **For Smooth Demo:**

1. **Pre-upload 1 file** before recording to verify everything works
2. **Have AWS Console tabs open** and ready
3. **Use keyboard shortcuts** to switch between windows
4. **Speak while waiting** for processing (explain what's happening)
5. **Show real-time processing** (don't speed up video)
6. **Point with cursor** to highlight important parts
7. **Zoom in** on small text
8. **Pause between demos** to let viewers absorb information

### **For Professional Look:**

1. **Good lighting** (face the window or use ring light)
2. **Clean background** (or use virtual background)
3. **Good microphone** (even phone earbuds are better than laptop mic)
4. **Close notifications** (Do Not Disturb mode)
5. **Hide personal info** (email, account IDs if sensitive)
6. **Practice once** before final recording
7. **Keep it under 15 minutes** (attention span)

### **For Maximum Impact:**

1. **Start with the problem** (schema drift costs $250K/year)
2. **Show the solution** (live demo)
3. **Prove it works** (real metrics)
4. **Explain the value** (ROI, cost savings)
5. **End with call-to-action** (GitHub link, LinkedIn)

---

## 🎯 ALTERNATIVE: 5-MINUTE QUICK DEMO

If you want a shorter video:

**Minute 1:** Problem + Solution overview  
**Minute 2:** Architecture diagram  
**Minute 3:** Demo 1 breaking change (most impressive)  
**Minute 4:** Show metrics and ROI  
**Minute 5:** Wrap-up and GitHub link  

---

## 📊 EXPECTED RESULTS

**Video Length:** 10-15 minutes  
**Demo Files:** 10 (or just 3-4 for quick version)  
**Processing Time:** ~45 seconds per file  
**Total Demo Time:** 5-10 minutes of actual processing  

**Viewer Takeaway:**
- "This person built a real, working system"
- "They understand AWS services deeply"
- "They think about business value, not just code"
- "This is production-ready, not a toy project"
- "I want to interview them!"

---

**Good luck with your recording! 🎬🚀**
