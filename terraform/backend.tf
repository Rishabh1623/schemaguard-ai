# Terraform Backend Configuration
# 
# BEST PRACTICE: Use remote state for production deployments
# For initial testing, local state is fine. Migrate to S3 backend later.
#
# Benefits of remote state:
# - Team collaboration
# - State locking (prevents conflicts)
# - State versioning and backup
# - Secure storage with encryption
#
# To enable remote state (OPTIONAL - do this after initial deployment):
#
# Step 1: Create S3 bucket for state
# aws s3 mb s3://schemaguard-terraform-state-$(aws sts get-caller-identity --query Account --output text)
# aws s3api put-bucket-versioning --bucket schemaguard-terraform-state-$(aws sts get-caller-identity --query Account --output text) --versioning-configuration Status=Enabled
#
# Step 2: Create DynamoDB table for state locking
# aws dynamodb create-table \
#   --table-name schemaguard-terraform-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1
#
# Step 3: Uncomment the backend block below and update bucket name
# Step 4: Run: terraform init -migrate-state
#
# terraform {
#   backend "s3" {
#     bucket         = "schemaguard-terraform-state-ACCOUNT_ID"  # Replace ACCOUNT_ID
#     key            = "schemaguard-ai/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "schemaguard-terraform-lock"
#   }
# }
#
# NOTE: For initial deployment, local state is perfectly fine.
# You can always migrate to remote state later without data loss.
