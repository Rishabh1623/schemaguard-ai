# 🎥 AWS Console Testing & Recording Guide

## Professional Testing via AWS Console for Portfolio Demo

**Purpose:** Test SchemaGuard AI using AWS Console for professional video recording  
**Best For:** Interviews, portfolio videos, LinkedIn demos  
**Duration:** 20-25 minutes  
**Visual Impact:** ⭐⭐⭐⭐⭐ (Highly impressive)

---

## 🎯 Why Use AWS Console for Testing?

### Advantages
✅ **Visual Appeal** - See resources in real-time  
✅ **Professional Look** - Shows AWS expertise  
✅ **Easy to Follow** - Viewers can see what's happening  
✅ **Demonstrates Skills** - Shows you know AWS Console navigation  
✅ **Better for Recording** - More engaging than terminal only  
✅ **Interview Ready** - Interviewers often ask about Console  

### Best Approach: Hybrid (Terminal + Console)
- **Deploy with Terminal** - Shows IaC skills (Terraform)
- **Test with Console** - Shows AWS navigation skills
- **Monitor with Both** - Shows comprehensive understanding

---

## 📋 PART 1: Pre-Recording Setup (5 minutes)

### Step 1.1: Deploy Infrastructure First

```bash
# On Ubuntu server - deploy via terminal
cd ~/schemaguard-ai/terraform
terraform apply

# Wait for completion
# Save outputs
terraform output > outputs.txt
```

### Step 1.2: Prepare AWS Console

**Open these tabs in your browser (in order):**

1. **S3 Console**
   - URL: https://s3.console.aws.amazon.com/s3/buckets
   - Filter: "schemaguard"
   - Keep this tab open

2. **Lambda Console**
   - URL: https://console.aws.amazon.com/lambda/home#/functions
   - Filter: "schemaguard"
   - Keep this tab open

3. **Step Functions Console**
   - URL: https://console.aws.amazon.com/states/home#/statemachines
   - Filter: "schemaguard"
   - Keep this tab open

4. **DynamoDB Console**
   - URL: https://console.aws.amazon.com/dynamodbv2/home#tables
   - Filter: "schemaguard"
   - Keep this tab open

5. **CloudWatch Logs Console**
   - URL: https://console.aws.amazon.com/cloudwatch/home#logsV2:log-groups
   - Filter: "schemaguard"
   - Keep this tab open

6. **Glue Console**
   - URL: https://console.aws.amazon.com/glue/home#/v2/data-catalog/databases
   - Keep this tab open

### Step 1.3: Browser Settings for Recording

```
Browser Zoom: 110-125% (easier to read in video)
Close unnecessary tabs
Hide bookmarks bar (Ctrl+Shift+B)
Use Incognito/Private mode (cleaner look)
Clear any notifications
Full screen mode (F11)
```

### Step 1.4: Prepare Test Data Files

**Create on your local machine (for easy upload via Console):**

**File 1: test-baseline.json** (matches contract)
```json
{
  "id": "baseline-001",
  "timestamp": 1704067200000,
  "event_type": "user_action",
  "user_id": "user-123",
  "data": {
    "action": "click",
    "target": "button"
  }
}
```

**File 2: test-drift-additive.json** (new field - additive change)
```json
{
  "id": "drift-001",
  "timestamp": 1704067200000,
  "event_type": "user_action",
  "user_id": "user-456",
  "user_location": "New York",
  "data": {
    "action": "scroll",
    "target": "page"
  }
}
```

**File 3: test-drift-breaking.json** (type change - breaking)
```json
{
  "id": "drift-002",
  "timestamp": "2024-01-01T00:00:00Z",
  "event_type": "system_event",
  "user_id": 789,
  "data": {
    "status": "active"
  }
}
```

Save these files on your desktop for easy access during recording.

---

## 🎬 PART 2: Recording Script with Console (20 minutes)

### Scene 1: Infrastructure Overview (3 minutes)

**What to Show:** AWS Console - All deployed resources

**Narration:**
```
"Let me show you the deployed infrastructure in AWS Console.

[Open S3 Console]
Here we have 6 S3 buckets for different pipeline stages:
- Raw bucket for data ingestion
- Staging for validation
- Curated for processed data
- Quarantine for problematic data
- Contracts for schema versions
- Scripts for code artifacts

[Open Lambda Console]
Four Lambda functions implementing our AI agents:
- Schema Analyzer - detects schema drift
- Contract Generator - proposes new contracts
- ETL Patch Agent - suggests code fixes
- Staging Validator - validates data quality

[Open Step Functions Console]
The orchestrator state machine that coordinates the entire workflow.

[Open DynamoDB Console]
Four DynamoDB tables for state management:
- Schema history for audit trails
- Contract approvals for governance
- Agent memory for learning
- Execution state for tracking

All of this was deployed with a single Terraform command - 
zero manual clicks."
```

**Screen Actions:**
1. Navigate through each console
2. Show resource counts
3. Highlight naming conventions
4. Show tags (Environment, Project)

---

### Scene 2: Upload Data Contract (2 minutes)

**What to Show:** S3 Console - Upload contract

**Narration:**
```
"First, let's upload the initial data contract that defines 
our expected schema.

[S3 Console → Contracts Bucket]
I'm opening the contracts bucket and uploading contract_v1.json.

[Click Upload → Add files → Select contract_v1.json]

This contract defines:
- Required fields: id, timestamp, event_type
- Optional fields: user_id, data
- Validation rules for each field
- Evolution policy: additive changes only

[Click Upload]

The contract is now in place. This is our baseline schema 
that all incoming data will be compared against."
```

**Screen Actions:**
1. Navigate to contracts bucket
2. Click "Upload"
3. Select contract_v1.json
4. Show file details
5. Click "Upload"
6. Verify upload success
7. Click on file to show content (optional)

---

### Scene 3: Test Baseline Data (4 minutes)

**What to Show:** S3 Upload → Step Functions Execution → CloudWatch Logs

**Narration:**
```
"Now let's test with data that matches our contract.

[S3 Console → Raw Bucket → data/ folder]
I'm uploading test-baseline.json to the raw bucket's data folder.

[Upload file]

The moment this file hits S3, EventBridge triggers our 
Step Functions workflow.

[Switch to Step Functions Console]
Watch - a new execution just started! Let's click on it.

[Click on latest execution]

Here's the visual workflow. You can see each state:
1. Schema Analyzer - running now
2. Classify Change - will determine if it's safe
3. Route based on classification
4. Execute ETL or quarantine

[Wait for Schema Analyzer to complete]

Schema Analyzer completed successfully. Let's look at the output.

[Click on Schema Analyzer state → Output tab]

The agent detected:
- Change type: NO_CHANGE
- All fields match the contract
- Risk level: LOW
- Recommendation: Proceed to ETL

[Switch to CloudWatch Logs]
Let's see the detailed logs.

[Open /aws/lambda/schemaguard-ai-dev-schema-analyzer]

Here you can see the complete analysis:
- Schema extracted from JSON
- Compared against contract
- No differences found
- Bedrock analysis confirmed it's safe

[Switch back to Step Functions]

The workflow is proceeding to the ETL job. In a real scenario, 
this would process the data and load it into the curated bucket."
```

**Screen Actions:**
1. S3: Upload test-baseline.json
2. Step Functions: Show new execution
3. Click on execution
4. Show visual workflow
5. Click on Schema Analyzer state
6. Show input/output
7. CloudWatch: Show logs
8. Back to Step Functions: Show completion

---

### Scene 4: Test Schema Drift - Additive Change (5 minutes)

**What to Show:** Upload drift file → Agent detects change → Impact analysis

**Narration:**
```
"Now let's see the real power - detecting schema drift.

I've prepared a test file with a new field called 'user_location' 
that's not in our contract. This is an additive change - not 
breaking, but needs to be tracked.

[S3 Console → Upload test-drift-additive.json]

Uploading now...

[Switch to Step Functions immediately]

Another execution started! Let's watch this one closely.

[Click on new execution]

Schema Analyzer is running... and it detected the change!

[Click on Schema Analyzer state → Output]

Look at the output:
- Change type: ADDITIVE
- Added fields: user_location (type: string)
- No removed fields
- No type changes

The agent classified this as an additive change, which means 
it's backward compatible but requires contract update.

[Show next state - Contract Generator]

The workflow routed to Contract Generator because this needs 
human approval. In production, this would:
1. Generate a new contract version (v2)
2. Store it in DynamoDB for approval
3. Send SNS notification to data team
4. Wait for human approval
5. Only then proceed to ETL

This is the governance in action - the agent detects changes, 
analyzes impact, proposes solutions, but doesn't blindly 
auto-deploy.

[Switch to DynamoDB Console]
Let's check the schema history table.

[Open schema-history table → Explore items]

Here's the record of this schema change:
- Schema ID
- Timestamp
- Incoming schema
- Expected schema
- Schema diff showing the new field
- Change classification: ADDITIVE
- Impact analysis from Bedrock

This creates a complete audit trail for compliance."
```

**Screen Actions:**
1. S3: Upload drift file
2. Step Functions: Show new execution
3. Click on execution
4. Show Schema Analyzer output (drift detected)
5. Show Contract Generator state
6. DynamoDB: Show schema history record
7. Highlight key fields in the record

---

### Scene 5: Test Breaking Change (3 minutes)

**What to Show:** Upload breaking change → Quarantine path

**Narration:**
```
"Let's test a breaking change - where the data type changed.

[S3 Console → Upload test-drift-breaking.json]

This file has:
- timestamp as string instead of number
- user_id as number instead of string

These are breaking changes that could crash the ETL.

[Switch to Step Functions]

New execution... Schema Analyzer running...

[Click on execution → Schema Analyzer output]

Detected:
- Change type: BREAKING
- Type changes: timestamp (number → string), user_id (string → number)
- Risk level: HIGH

[Show workflow routing]

The workflow routed to the Quarantine path! The data is being 
moved to the quarantine bucket instead of processing.

[Switch to S3 → Quarantine bucket]

Here's the quarantined file. It's isolated and won't corrupt 
our curated data.

[Switch to SNS or show email]

An SNS notification was sent to the data team alerting them 
of the breaking change.

This demonstrates the safety mechanisms - breaking changes 
are caught before they cause production failures."
```

**Screen Actions:**
1. S3: Upload breaking change file
2. Step Functions: Show execution
3. Show BREAKING classification
4. Show quarantine routing
5. S3: Show file in quarantine bucket
6. (Optional) Show SNS notification

---

### Scene 6: Monitoring & Observability (3 minutes)

**What to Show:** CloudWatch dashboards, metrics, logs

**Narration:**
```
"Let's look at monitoring and observability.

[CloudWatch Logs Console]

Every component has centralized logging:
- Lambda functions log every execution
- Step Functions log state transitions
- Glue jobs log ETL processing

[Open a log stream]

Logs are structured with:
- Timestamps
- Execution IDs for tracing
- Detailed error messages
- Performance metrics

[CloudWatch Metrics - if available]

We can track:
- Lambda invocation counts
- Step Functions execution success rate
- DynamoDB read/write capacity
- S3 storage usage

[Show log retention]

Logs are retained for 30 days for cost optimization, 
but can be extended for compliance requirements.

[DynamoDB Console → Schema History table]

The schema history table provides a complete audit trail:
- Every schema change detected
- When it was detected
- Who/what triggered it
- What the impact was
- What action was taken

This is critical for:
- Compliance audits
- Troubleshooting
- Understanding data evolution
- Training the agent"
```

**Screen Actions:**
1. CloudWatch: Show log groups
2. Open log stream
3. Show structured logs
4. Show metrics (if available)
5. DynamoDB: Show audit trail
6. Highlight compliance features

---

### Scene 7: Cost Optimization Features (2 minutes)

**What to Show:** S3 lifecycle, DynamoDB settings, resource tags

**Narration:**
```
"Let's talk about cost optimization built into the system.

[S3 Console → Raw bucket → Management → Lifecycle]

S3 lifecycle policies automatically:
- Move data to Intelligent Tiering after 30 days (70% savings)
- Delete data after 90 days
- Clean staging data after 7 days

[DynamoDB Console → Schema History table → Additional settings]

DynamoDB uses:
- Pay-per-request billing (no capacity planning)
- TTL for automatic data expiration
- Point-in-time recovery for disaster recovery

[Show resource tags]

Every resource is tagged for:
- Cost allocation
- Environment tracking
- Project identification

This enables detailed cost tracking and optimization.

Current costs for this dev environment: $7-12 per month.
That's 30-40% cheaper than traditional approaches because:
- Serverless (no idle resources)
- Pay-per-request (no over-provisioning)
- Automatic lifecycle management
- Efficient resource sizing"
```

**Screen Actions:**
1. S3: Show lifecycle rules
2. DynamoDB: Show billing mode
3. Show TTL configuration
4. Show resource tags
5. (Optional) Show Cost Explorer

---

### Scene 8: Wrap Up & Architecture Review (2 minutes)

**What to Show:** Architecture diagram, GitHub repo

**Narration:**
```
"Let's review what we've demonstrated.

[Show architecture diagram or README]

SchemaGuard AI implements:

1. Event-driven architecture - S3 → EventBridge → Step Functions
2. Agentic AI - Agent with tools, memory, and bounded decisions
3. Governance - Human approval gates for breaking changes
4. Observability - Complete logging and audit trails
5. Cost optimization - Serverless, pay-per-request, lifecycle policies
6. Security - Encryption, least privilege, no public access

The system follows AWS Well-Architected Framework:
- Operational Excellence: IaC, monitoring, automation
- Security: Encryption, IAM, audit trails
- Reliability: Multi-AZ, retries, error handling
- Performance: Right-sized, serverless, event-driven
- Cost Optimization: Pay-per-request, lifecycle, tagging

[Show GitHub repository]

Complete code and documentation available at:
github.com/Rishabh1623/schemaguard-ai

This demonstrates production-grade AWS architecture solving 
a real business problem: preventing schema drift failures 
in data pipelines.

Thank you for watching!"
```

**Screen Actions:**
1. Show architecture diagram
2. Highlight key components
3. Show GitHub repository
4. Scroll through documentation
5. End on repo homepage

---

## 🎨 OBS Recording Tips for Console

### Browser Setup
```
Resolution: 1920x1080
Zoom: 125% (easier to read)
Full screen: F11
Hide bookmarks: Ctrl+Shift+B
Private/Incognito mode (cleaner)
Close unnecessary tabs
```

### OBS Scenes

**Scene 1: Full Browser**
- Capture: Browser window
- Use for: Console navigation

**Scene 2: Split Screen**
- Left: Terminal (for commands)
- Right: Browser (for results)
- Use for: Showing cause and effect

**Scene 3: Picture-in-Picture**
- Main: Browser
- Corner: Webcam (optional)
- Use for: Introduction/conclusion

### Recording Settings
```
Resolution: 1920x1080
FPS: 30
Bitrate: 6000-8000 Kbps
Encoder: x264 or NVENC
Audio: Clear microphone, -12 to -6 dB
```

---

## 📋 Console Navigation Shortcuts

### Quick Navigation
```
Alt+S → S3
Alt+L → Lambda
Alt+F → Step Functions
Alt+D → DynamoDB
Alt+C → CloudWatch
Ctrl+K → AWS search bar
```

### Browser Shortcuts
```
Ctrl+T → New tab
Ctrl+W → Close tab
Ctrl+Tab → Next tab
Ctrl+Shift+Tab → Previous tab
F5 → Refresh
F11 → Full screen
```

---

## ✅ Pre-Recording Checklist

### AWS Console
- [ ] All tabs open and organized
- [ ] Browser zoom set to 125%
- [ ] Bookmarks hidden
- [ ] Notifications cleared
- [ ] Full screen mode ready (F11)

### Test Files
- [ ] test-baseline.json on desktop
- [ ] test-drift-additive.json on desktop
- [ ] test-drift-breaking.json on desktop
- [ ] Files easy to access

### Infrastructure
- [ ] Terraform deployed successfully
- [ ] All resources verified
- [ ] SNS subscription confirmed
- [ ] Contract uploaded

### OBS
- [ ] Recording settings configured
- [ ] Audio tested
- [ ] Browser capture working
- [ ] Test recording done

### Narration
- [ ] Script reviewed
- [ ] Talking points memorized
- [ ] Confident and ready

---

## 🎯 Professional Tips

### Do's ✅
- **Navigate confidently** - Know where things are
- **Explain as you click** - Narrate your actions
- **Show, don't just tell** - Click through to details
- **Highlight key information** - Point out important fields
- **Use consistent naming** - Refer to resources consistently
- **Show the business value** - Explain why it matters

### Don'ts ❌
- **Don't rush** - Give viewers time to see
- **Don't skip errors** - Show how you troubleshoot
- **Don't apologize** - Edit out mistakes
- **Don't read everything** - Highlight key points
- **Don't get lost** - Know your navigation path
- **Don't forget context** - Explain what you're showing

---

## 🎬 Sample Opening Script

```
"Hi, I'm [Name]. Today I'm demonstrating SchemaGuard AI - 
a production-grade agentic AI platform I built for ETL 
reliability on AWS.

I've already deployed the infrastructure using Terraform - 
30+ AWS resources with a single command. Now I'll show you 
how the system works using the AWS Console.

We'll test three scenarios:
1. Baseline data that matches our contract
2. Additive schema change (new field)
3. Breaking schema change (type mismatch)

You'll see how the AI agent detects changes, analyzes impact, 
and implements governed remediation workflows - all in real-time.

Let's start by looking at the deployed infrastructure..."
```

---

## 🎬 Sample Closing Script

```
"To summarize what we've seen:

The system successfully:
- Detected schema changes in real-time
- Classified them as additive or breaking
- Routed data appropriately (process or quarantine)
- Maintained complete audit trails
- Implemented governance gates

This demonstrates:
- Multi-service AWS integration (10+ services)
- Event-driven serverless architecture
- Agentic AI with bounded decision-making
- Production-grade observability
- Cost-optimized design

All code and documentation are available on GitHub at
github.com/Rishabh1623/schemaguard-ai

This project showcases the skills needed for AWS Solutions 
Architect roles: architecture design, service integration, 
cost optimization, and operational excellence.

Thanks for watching!"
```

---

## 📊 Recording Timeline

| Time | Scene | Focus |
|------|-------|-------|
| 0:00-3:00 | Infrastructure Overview | Show all resources |
| 3:00-5:00 | Upload Contract | S3 upload |
| 5:00-9:00 | Test Baseline | Step Functions + Logs |
| 9:00-14:00 | Test Drift (Additive) | Agent detection |
| 14:00-17:00 | Test Breaking Change | Quarantine path |
| 17:00-20:00 | Monitoring | CloudWatch + DynamoDB |
| 20:00-22:00 | Cost Optimization | Lifecycle + Tags |
| 22:00-25:00 | Wrap Up | Architecture + GitHub |

---

## 🎯 Success Criteria

Your recording is successful when viewers can see:

- ✅ Complete AWS infrastructure deployed
- ✅ Real-time event-driven processing
- ✅ AI agent detecting schema changes
- ✅ Governance gates in action
- ✅ Data being quarantined when unsafe
- ✅ Complete audit trails
- ✅ Professional AWS Console navigation
- ✅ Clear explanation of business value

---

## 📚 Additional Resources

### AWS Console URLs (Bookmark These)
- S3: https://s3.console.aws.amazon.com/s3/
- Lambda: https://console.aws.amazon.com/lambda/
- Step Functions: https://console.aws.amazon.com/states/
- DynamoDB: https://console.aws.amazon.com/dynamodb/
- CloudWatch: https://console.aws.amazon.com/cloudwatch/
- Glue: https://console.aws.amazon.com/glue/
- Bedrock: https://console.aws.amazon.com/bedrock/

### Practice Navigation
- Spend 10 minutes clicking through each console
- Know where key information is located
- Practice the flow before recording
- Have backup tabs ready

---

## 🎉 You're Ready!

**Using AWS Console for testing makes your demo:**
- More visual and engaging
- Easier for viewers to follow
- More professional looking
- Better for interviews
- Shows comprehensive AWS knowledge

**Combine with terminal for best results:**
- Deploy with Terraform (shows IaC skills)
- Test with Console (shows AWS navigation)
- Monitor with both (shows complete understanding)

**Good luck with your recording!** 🎯

---

*Guide Version: 1.0*  
*Last Updated: December 31, 2025*  
*Project: SchemaGuard AI*
