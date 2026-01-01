#!/bin/bash
# SchemaGuard AI - Push to GitHub Script
# Repository: https://github.com/Rishabh1623/schemaguard-ai

set -e  # Exit on error

echo "🚀 SchemaGuard AI - GitHub Push Script"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

echo -e "${BLUE}📁 Current directory:${NC} $(pwd)"
echo ""

# Step 1: Initialize Git
echo -e "${YELLOW}Step 1: Initializing Git repository...${NC}"
if [ -d .git ]; then
    echo "✅ Git repository already initialized"
else
    git init
    echo "✅ Git repository initialized"
fi
echo ""

# Step 2: Create .gitignore
echo -e "${YELLOW}Step 2: Creating .gitignore...${NC}"
cat > .gitignore << 'EOF'
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
.terraform/
.terraform.lock.hcl
terraform.tfplan
deployment-outputs.txt

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
ENV/
env/
*.egg-info/
package/

# Lambda packages
*.zip

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# AWS
.aws/

# Environment
.env
.env.local
.schemaguard-env

# Logs
*.log
logs/

# Temporary
tmp/
temp/
response.json

# OS
Thumbs.db
EOF
echo "✅ .gitignore created"
echo ""

# Step 3: Create LICENSE
echo -e "${YELLOW}Step 3: Creating LICENSE...${NC}"
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Rishabh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
echo "✅ LICENSE created"
echo ""

# Step 4: Create terraform.tfvars.example
echo -e "${YELLOW}Step 4: Creating terraform.tfvars.example...${NC}"
cat > terraform/terraform.tfvars.example << 'EOF'
# Example Terraform variables file
# Copy this to terraform.tfvars and update with your values

project_name      = "schemaguard-ai"
environment       = "dev"
aws_region        = "us-east-1"
notification_email = "your-email@example.com"  # CHANGE THIS
bedrock_model_id  = "anthropic.claude-3-sonnet-20240229-v1:0"

glue_python_version     = "3"
glue_worker_type        = "G.1X"
glue_number_of_workers  = 2

schema_retention_days     = 90
quarantine_retention_days = 30

enable_point_in_time_recovery = true

tags = {
  Project     = "SchemaGuard-AI"
  ManagedBy   = "Terraform"
  Purpose     = "Agentic-ETL-Platform"
  Owner       = "Rishabh"
}
EOF
echo "✅ terraform.tfvars.example created"
echo ""

# Step 5: Stage all files
echo -e "${YELLOW}Step 5: Staging files...${NC}"
git add .
echo "✅ Files staged"
echo ""

# Show what will be committed
echo -e "${BLUE}📋 Files to be committed:${NC}"
git status --short
echo ""

# Step 6: Create initial commit
echo -e "${YELLOW}Step 6: Creating initial commit...${NC}"
git commit -m "Initial commit: SchemaGuard AI - Agentic Self-Healing ETL Platform

Features:
- 10+ AWS services integration (S3, Lambda, Step Functions, Glue, DynamoDB, Bedrock, etc.)
- Agent-driven workflow with Amazon Bedrock for intelligent automation
- Complete Terraform infrastructure as code
- Multi-stage validation pipeline (staging → validation → production)
- Human-in-the-loop governance and approval workflows
- Comprehensive documentation and deployment guides
- Production-ready with security, observability, and cost optimization

Architecture:
- Event-driven serverless design
- Schema drift detection and remediation
- Agentic AI for impact analysis and decision-making
- Quarantine mechanism for problematic data
- Complete audit trail and rollback capability

Documentation:
- COMPLETE_DEPLOYMENT_GUIDE.md - Full AWS CLI deployment guide
- QUICK_COMMANDS.sh - Reusable bash functions
- README_UBUNTU.md - Ubuntu-specific quick start
- Comprehensive Terraform configuration

This project demonstrates senior-level AWS Solutions Architect skills."

echo "✅ Initial commit created"
echo ""

# Step 7: Add remote
echo -e "${YELLOW}Step 7: Adding GitHub remote...${NC}"
REPO_URL="https://github.com/Rishabh1623/schemaguard-ai.git"

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "⚠️  Remote 'origin' already exists. Updating URL..."
    git remote set-url origin $REPO_URL
else
    git remote add origin $REPO_URL
fi

echo "✅ Remote added: $REPO_URL"
echo ""

# Verify remote
echo -e "${BLUE}🔗 Remote repository:${NC}"
git remote -v
echo ""

# Step 8: Rename branch to main
echo -e "${YELLOW}Step 8: Setting branch to 'main'...${NC}"
git branch -M main
echo "✅ Branch set to 'main'"
echo ""

# Step 9: Push to GitHub
echo -e "${YELLOW}Step 9: Pushing to GitHub...${NC}"
echo ""
echo "⚠️  You will be prompted for GitHub credentials:"
echo "   Username: Rishabh1623"
echo "   Password: Use your Personal Access Token (not your GitHub password)"
echo ""
echo "   Create token at: https://github.com/settings/tokens"
echo "   Required scopes: repo (full control)"
echo ""
read -p "Press Enter to continue with push..."
echo ""

# Push to GitHub
if git push -u origin main; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
    echo ""
    echo -e "${GREEN}🎉 Success! Your project is now on GitHub!${NC}"
    echo ""
    echo -e "${BLUE}🌐 View your repository at:${NC}"
    echo "   https://github.com/Rishabh1623/schemaguard-ai"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "   1. Visit your repository on GitHub"
    echo "   2. Add repository description and topics"
    echo "   3. Pin repository to your profile"
    echo "   4. Share on LinkedIn"
    echo "   5. Add to your resume/portfolio"
    echo ""
    echo -e "${BLUE}💡 Suggested topics for GitHub:${NC}"
    echo "   aws, terraform, serverless, etl, data-engineering,"
    echo "   amazon-bedrock, step-functions, lambda, agentic-ai,"
    echo "   solutions-architect, python, infrastructure-as-code"
    echo ""
else
    echo ""
    echo -e "${YELLOW}⚠️  Push failed. Common issues:${NC}"
    echo ""
    echo "1. Authentication failed:"
    echo "   - Make sure you're using a Personal Access Token, not your password"
    echo "   - Create token at: https://github.com/settings/tokens"
    echo ""
    echo "2. Repository not empty:"
    echo "   - Run: git pull origin main --allow-unrelated-histories"
    echo "   - Then: git push origin main"
    echo ""
    echo "3. Network issues:"
    echo "   - Check your internet connection"
    echo "   - Try again in a few moments"
    echo ""
    exit 1
fi

# Create a summary file
cat > GITHUB_PUSH_SUMMARY.txt << EOF
SchemaGuard AI - GitHub Push Summary
====================================

Repository: https://github.com/Rishabh1623/schemaguard-ai
Pushed: $(date)

Files Pushed:
- Documentation: 8 files
- Terraform: 10 files
- Step Functions: 1 file
- Scripts: 2 files
- Configuration: 2 files

Total: 23+ files

Next Steps:
1. Visit: https://github.com/Rishabh1623/schemaguard-ai
2. Add description: "Production-grade agentic ETL platform using AWS Bedrock, Step Functions, and 10+ services"
3. Add topics: aws, terraform, serverless, etl, amazon-bedrock, agentic-ai
4. Pin to profile
5. Share on LinkedIn

LinkedIn Post Template:
-----------------------
🚀 Excited to share SchemaGuard AI - my latest AWS project!

Built a production-grade, agent-driven ETL reliability platform featuring:
✅ 10+ AWS services (Lambda, Step Functions, Bedrock, Glue, DynamoDB)
✅ Agentic AI for intelligent automation
✅ Complete Terraform infrastructure
✅ Event-driven serverless architecture

Demonstrates real-world AWS Solutions Architect skills!

Check it out: https://github.com/Rishabh1623/schemaguard-ai

#AWS #CloudArchitecture #DataEngineering #AI #Terraform
EOF

echo -e "${GREEN}📄 Summary saved to: GITHUB_PUSH_SUMMARY.txt${NC}"
echo ""
