# Terraform Backend Configuration
# Uncomment and configure for remote state management

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "schemaguard-ai/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# To use remote state:
# 1. Create S3 bucket for state: aws s3 mb s3://your-terraform-state-bucket
# 2. Create DynamoDB table for locking:
#    aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST
# 3. Uncomment the backend block above
# 4. Run: terraform init -migrate-state
