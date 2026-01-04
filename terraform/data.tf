# Data sources for dynamic AWS information
# This makes the code portable across accounts and regions

data "aws_caller_identity" "current" {
  # Gets current AWS account ID
}

data "aws_partition" "current" {
  # Gets AWS partition (aws, aws-cn, aws-us-gov)
}

data "aws_region" "current" {
  # Gets current AWS region
}

# Archive Lambda functions for deployment
# This creates zip files from Python code automatically
data "archive_file" "schema_analyzer" {
  type        = "zip"
  source_file = "${path.module}/../agents/schema_analyzer.py"
  output_path = "${path.module}/../agents/schema_analyzer.zip"
}

data "archive_file" "contract_generator" {
  type        = "zip"
  source_file = "${path.module}/../agents/contract_generator.py"
  output_path = "${path.module}/../agents/contract_generator.zip"
}

data "archive_file" "etl_patch_agent" {
  type        = "zip"
  source_file = "${path.module}/../agents/etl_patch_agent.py"
  output_path = "${path.module}/../agents/etl_patch_agent.zip"
}

data "archive_file" "staging_validator" {
  type        = "zip"
  source_file = "${path.module}/../agents/staging_validator.py"
  output_path = "${path.module}/../agents/staging_validator.zip"
}
