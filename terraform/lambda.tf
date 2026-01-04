# Lambda functions for agent components
# Using archive_file data source for automatic packaging (low-code approach)

# Schema Analyzer Lambda
resource "aws_lambda_function" "schema_analyzer" {
  filename         = data.archive_file.schema_analyzer.output_path
  function_name    = local.lambda_names.schema_analyzer
  role            = aws_iam_role.lambda_agent.arn
  handler         = "schema_analyzer.lambda_handler"
  source_code_hash = data.archive_file.schema_analyzer.output_base64sha256
  runtime         = local.lambda_runtime
  timeout         = local.lambda_timeout
  memory_size     = local.lambda_memory_size

  environment {
    variables = {
      SCHEMA_HISTORY_TABLE = aws_dynamodb_table.schema_history.name
      AGENT_MEMORY_TABLE   = aws_dynamodb_table.agent_memory.name
      CONTRACTS_BUCKET     = aws_s3_bucket.contracts.id
      BEDROCK_MODEL_ID     = var.bedrock_model_id
      ENVIRONMENT          = var.environment
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Schema Analyzer"
      Component = "Agent"
    }
  )
}

# Contract Generator Lambda
resource "aws_lambda_function" "contract_generator" {
  filename         = data.archive_file.contract_generator.output_path
  function_name    = local.lambda_names.contract_generator
  role            = aws_iam_role.lambda_agent.arn
  handler         = "contract_generator.lambda_handler"
  source_code_hash = data.archive_file.contract_generator.output_base64sha256
  runtime         = local.lambda_runtime
  timeout         = local.lambda_timeout
  memory_size     = local.lambda_memory_size

  environment {
    variables = {
      CONTRACT_APPROVALS_TABLE = aws_dynamodb_table.contract_approvals.name
      CONTRACTS_BUCKET         = aws_s3_bucket.contracts.id
      BEDROCK_MODEL_ID         = var.bedrock_model_id
      ENVIRONMENT              = var.environment
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Contract Generator"
      Component = "Agent"
    }
  )
}

# ETL Patch Agent Lambda
resource "aws_lambda_function" "etl_patch_agent" {
  filename         = data.archive_file.etl_patch_agent.output_path
  function_name    = local.lambda_names.etl_patch_agent
  role            = aws_iam_role.lambda_agent.arn
  handler         = "etl_patch_agent.lambda_handler"
  source_code_hash = data.archive_file.etl_patch_agent.output_base64sha256
  runtime         = local.lambda_runtime
  timeout         = local.lambda_timeout
  memory_size     = local.lambda_memory_size

  environment {
    variables = {
      SCRIPTS_BUCKET   = aws_s3_bucket.scripts.id
      BEDROCK_MODEL_ID = var.bedrock_model_id
      ENVIRONMENT      = var.environment
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard ETL Patch Agent"
      Component = "Agent"
    }
  )
}

# Staging Validator Lambda
resource "aws_lambda_function" "staging_validator" {
  filename         = data.archive_file.staging_validator.output_path
  function_name    = local.lambda_names.staging_validator
  role            = aws_iam_role.lambda_agent.arn
  handler         = "staging_validator.lambda_handler"
  source_code_hash = data.archive_file.staging_validator.output_base64sha256
  runtime         = local.lambda_runtime
  timeout         = 600  # Longer timeout for Athena queries
  memory_size     = 1024  # More memory for data processing

  environment {
    variables = {
      STAGING_BUCKET        = aws_s3_bucket.staging.id
      CURATED_BUCKET        = aws_s3_bucket.curated.id
      GLUE_DATABASE         = aws_glue_catalog_database.schemaguard.name
      ATHENA_OUTPUT_BUCKET  = aws_s3_bucket.staging.id
      ENVIRONMENT           = var.environment
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Staging Validator"
      Component = "Agent"
    }
  )
}

# CloudWatch Log Groups for Lambda functions (centralized configuration)
resource "aws_cloudwatch_log_group" "schema_analyzer" {
  name              = "/aws/lambda/${aws_lambda_function.schema_analyzer.function_name}"
  retention_in_days = local.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "contract_generator" {
  name              = "/aws/lambda/${aws_lambda_function.contract_generator.function_name}"
  retention_in_days = local.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "etl_patch_agent" {
  name              = "/aws/lambda/${aws_lambda_function.etl_patch_agent.function_name}"
  retention_in_days = local.log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "staging_validator" {
  name              = "/aws/lambda/${aws_lambda_function.staging_validator.function_name}"
  retention_in_days = local.log_retention_days

  tags = local.common_tags
}
