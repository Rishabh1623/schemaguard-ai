# Local values for reusability and DRY principle
# This reduces code duplication and makes maintenance easier

locals {
  # Account and partition info
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  
  # Resource naming
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CostCenter  = "DataPlatform"
      Owner       = "DataEngineering"
    }
  )
  
  # Lambda configuration (DRY principle)
  lambda_runtime     = "python3.11"
  lambda_timeout     = 300
  lambda_memory_size = 512
  
  # S3 bucket names with account ID for global uniqueness
  bucket_names = {
    raw        = "${local.resource_prefix}-raw-${local.account_id}"
    staging    = "${local.resource_prefix}-staging-${local.account_id}"
    curated    = "${local.resource_prefix}-curated-${local.account_id}"
    quarantine = "${local.resource_prefix}-quarantine-${local.account_id}"
    contracts  = "${local.resource_prefix}-contracts-${local.account_id}"
    scripts    = "${local.resource_prefix}-scripts-${local.account_id}"
  }
  
  # DynamoDB table names
  table_names = {
    schema_history      = "${local.resource_prefix}-schema-history"
    contract_approvals  = "${local.resource_prefix}-contract-approvals"
    agent_memory        = "${local.resource_prefix}-agent-memory"
    execution_state     = "${local.resource_prefix}-execution-state"
  }
  
  # Lambda function names
  lambda_names = {
    schema_analyzer    = "${local.resource_prefix}-schema-analyzer"
    contract_generator = "${local.resource_prefix}-contract-generator"
    etl_patch_agent    = "${local.resource_prefix}-etl-patch-agent"
    staging_validator  = "${local.resource_prefix}-staging-validator"
  }
  
  # CloudWatch log retention (centralized)
  log_retention_days = 30
  
  # Cost optimization: Lifecycle policies
  lifecycle_policies = {
    raw_archive_days     = 30
    raw_expiration_days  = 90
    staging_cleanup_days = 7
    quarantine_days      = var.quarantine_retention_days
  }
}
