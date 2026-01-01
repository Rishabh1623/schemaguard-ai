# SchemaGuard AI — Agentic Self-Healing ETL Platform

## Overview

SchemaGuard AI is a production-grade, agent-driven ETL reliability platform that proactively detects schema drift, assesses impact, and safely remediates issues using governed AI workflows.

## Problem Statement

Modern data platforms face constant schema evolution from upstream applications. Traditional ETL pipelines detect issues **after failure**, leading to:
- Silent data corruption
- Production failures during critical reporting windows
- Manual troubleshooting delays
- Repeated incidents from the same patterns

## Solution

SchemaGuard AI treats schema drift as a **controlled change event** with an AI agent that:
1. Understands how data changed
2. Evaluates if changes are safe or breaking
3. Proposes contract updates or ETL patches
4. Validates fixes in staging
5. Controls production execution with governance

## Architecture

```
┌─────────────┐
│   S3 Raw    │ ──► EventBridge ──► Step Functions (Agent Orchestrator)
└─────────────┘                              │
                                             ├──► Schema Detector
                                             ├──► Bedrock Agent (Impact Analysis)
                                             ├──► Contract Generator
                                             ├──► ETL Patch Agent
                                             ├──► Staging Validator
                                             └──► Production Controller
                                                       │
                                                       ├──► AWS Glue ETL
                                                       ├──► Athena Validation
                                                       └──► S3 Curated / Quarantine
```

## Key Components

### 1. Schema Detection
- Extracts schema from incoming JSON in S3
- Compares against expected schema (DynamoDB)
- Identifies additive vs breaking changes

### 2. Agent Orchestration (Step Functions)
- Analyzes schema diff and downstream impact
- Classifies risk: safe / risky / breaking
- Decides: proceed / quarantine / propose change

### 3. Data Contract Management
- Versioned JSON contracts
- Agent generates `contract_vNext.json` proposals
- Requires human approval before applying

### 4. Auto-Patch Proposal (Guardrailed)
- Generates minimal Glue ETL code diffs
- Limited to schema handling improvements
- **Never deploys directly to production**

### 5. Staging Validation
- Executes patched ETL on staging data
- Validates row counts, nulls, Athena queries
- Blocks production if validation fails

### 6. Controlled Production Execution
- Applies approved contracts
- Runs Glue ETL in production
- Quarantines data on failure with notifications

## AWS Services Used

- **S3**: Data storage (raw, quarantine, curated)
- **EventBridge**: Event-driven triggers
- **Step Functions**: Agent workflow orchestration
- **AWS Glue**: Serverless ETL execution
- **Amazon Athena**: Data validation queries
- **DynamoDB**: Schema history, approvals, agent memory
- **Amazon Bedrock**: Agent reasoning and decision-making
- **CloudWatch**: Observability and alerting
- **SNS**: Notifications
- **Terraform**: Infrastructure as Code

## Project Structure

```
schemaguard-ai/
├── terraform/              # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── glue.tf
│   ├── step-functions.tf
│   └── sns.tf
├── step-functions/         # Agent orchestration
│   └── schemaguard-state-machine.json
├── agents/                 # AI agent components
│   ├── schema_analyzer.py
│   ├── contract_generator.py
│   ├── etl_patch_agent.py
│   └── staging_validator.py
├── glue/                   # ETL jobs
│   └── etl_job.py
├── contracts/              # Data contract versions
│   ├── contract_v1.json
│   └── contract_v2.json
├── validation/             # Staging validation
│   └── staging_checks.py
├── tests/                  # Test scenarios
│   └── test_schema_drift.py
└── docs/                   # Documentation
    └── architecture.md
```

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.5
- Python 3.11+
- AWS CLI configured

### Deployment

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Review and apply infrastructure
terraform plan
terraform apply

# 3. Deploy agent code
cd ../agents
pip install -r requirements.txt

# 4. Upload initial data contract
aws s3 cp ../contracts/contract_v1.json s3://schemaguard-contracts/

# 5. Test with sample data
python ../tests/test_schema_drift.py
```

## Demo Scenario

1. **Upload schema-drifted JSON** to S3 raw bucket
2. **Agent detects drift** and analyzes impact
3. **Proposes contract v2** + ETL patch
4. **Validation passes** in staging
5. **Production ETL succeeds** with new schema

## Safety Guarantees

✅ No hard-coded schemas  
✅ No blind auto-deploys  
✅ Human-in-the-loop approval mandatory  
✅ Idempotent execution  
✅ Full observability  
✅ Rollback support  

## Measurable Outcomes

- Prevented schema-related ETL failures before execution
- Reduced incident response time from hours to minutes
- Eliminated recurring failures from uncoordinated changes
- Introduced reusable pattern for governed data evolution

## Why This is Agentic

The AI agent:
- **Has tools**: schema diff, validation checks, ETL test runs
- **Makes decisions**: within defined boundaries
- **Maintains memory**: past schema changes and outcomes
- **Operates under constraints**: explicit safety and approval gates

This demonstrates real agent design, not just LLM automation.

## Documentation

- **Quick Start**: See `QUICKSTART.md`
- **Deployment**: See `DEPLOYMENT.md`
- **Architecture**: See `docs/architecture.md`
- **Project Summary**: See `PROJECT_SUMMARY.md`

## License

MIT

## Author

Built as a demonstration of production-grade agentic AI architecture for enterprise data platforms.
