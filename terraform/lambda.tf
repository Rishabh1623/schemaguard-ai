# Lambda functions for agent components

# Schema Analyzer Lambda
resource "aws_lambda_function" "schema_analyzer" {
  filename         = "${path.module}/../agents/schema_analyzer.zip"
  function_name    = "${local.resource_prefix}-schema-analyzer"
  role            = aws_iam_role.lambda_agent.arn
  handler         = "schema_analyzer.lambda_handler"
  source_code_hash = fileexists("${path.module}/../agents/schema_analyzer.zip") ? filebase64sha256("${path.module}/../agents/schema_analyzer.zip") : null
  runtime         = "python3.11"
  timeout         = 300
  memory_size     = 512

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
    }
  )
}

# Contract Generator Lambda
resource "aws_lambda_function" "contract_generator" {
  filename         = "${path.module}/../agents/contract_generator.zip"
  function_name    = "${local.resource_prefix}-contract-generator"
  role            = aws_iam_role.lambda_agent.arn
  handler         = "contract_generator.lambda_handler"
  source_code_hash = fileexists("${path.module}/../agents/contract_generator.zip") ? filebase64sha256("${path.module}/../agents/contract_generator.zip") : null
  runtime         = "python3.11"
  timeout         = 300
  memory_size     = 512

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
    }
  )
}

# ETL Patch Agent Lambda
resource "aws_lambda_function" "etl_patch_agent" {
  filename         = "${path.module}/../agents/etl_patch_agent.zip"
  function_name    = "${local.resource_prefix}-etl-patch-agent"
  role            = aws_iam_role.lambda_agent.arn
  handler         = "etl_patch_agent.lambda_handler"
  source_code_hash = fileexists("${path.module}/../agents/etl_patch_agent.zip") ? filebase64sha256("${path.module}/../agents/etl_patch_agent.zip") : null
  runtime         = "python3.11"
  timeout         = 300
  memory_size     = 512

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
    }
  )
}

# Staging Validator Lambda
resource "aws_lambda_function" "staging_validator" {
  filename         = "${path.module}/../agents/staging_validator.zip"
  function_name    = "${local.resource_prefix}-staging-validator"
  role            = aws_iam_role.lambda_agent.arn
  handler         = "staging_validator.lambda_handler"
  source_code_hash = fileexists("${path.module}/../agents/staging_validator.zip") ? filebase64sha256("${path.module}/../agents/staging_validator.zip") : null
  runtime         = "python3.11"
  timeout         = 600
  memory_size     = 1024

  environment {
    variables = {
      STAGING_BUCKET   = aws_s3_bucket.staging.id
      CURATED_BUCKET   = aws_s3_bucket.curated.id
      ATHENA_DATABASE  = aws_glue_catalog_database.schemaguard.name
      ATHENA_OUTPUT    = "s3://${aws_s3_bucket.staging.id}/athena-results/"
      ENVIRONMENT      = var.environment
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Staging Validator"
    }
  )
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "schema_analyzer" {
  name              = "/aws/lambda/${aws_lambda_function.schema_analyzer.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "contract_generator" {
  name              = "/aws/lambda/${aws_lambda_function.contract_generator.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "etl_patch_agent" {
  name              = "/aws/lambda/${aws_lambda_function.etl_patch_agent.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "staging_validator" {
  name              = "/aws/lambda/${aws_lambda_function.staging_validator.function_name}"
  retention_in_days = 30

  tags = local.common_tags
}
