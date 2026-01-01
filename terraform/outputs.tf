# Terraform outputs for SchemaGuard AI

output "raw_bucket_name" {
  description = "S3 bucket for raw data ingestion"
  value       = aws_s3_bucket.raw.id
}

output "curated_bucket_name" {
  description = "S3 bucket for curated/processed data"
  value       = aws_s3_bucket.curated.id
}

output "quarantine_bucket_name" {
  description = "S3 bucket for quarantined data"
  value       = aws_s3_bucket.quarantine.id
}

output "contracts_bucket_name" {
  description = "S3 bucket for data contracts"
  value       = aws_s3_bucket.contracts.id
}

output "scripts_bucket_name" {
  description = "S3 bucket for scripts and code"
  value       = aws_s3_bucket.scripts.id
}

output "glue_job_name" {
  description = "Name of the Glue ETL job"
  value       = aws_glue_job.etl_job.name
}

output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.schemaguard.name
}

output "step_functions_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.schemaguard_orchestrator.arn
}

output "schema_history_table" {
  description = "DynamoDB table for schema history"
  value       = aws_dynamodb_table.schema_history.name
}

output "contract_approvals_table" {
  description = "DynamoDB table for contract approvals"
  value       = aws_dynamodb_table.contract_approvals.name
}

output "agent_memory_table" {
  description = "DynamoDB table for agent memory"
  value       = aws_dynamodb_table.agent_memory.name
}

output "execution_state_table" {
  description = "DynamoDB table for execution state"
  value       = aws_dynamodb_table.execution_state.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.schema_drift_alerts.arn
}

output "lambda_functions" {
  description = "Lambda function names for agent components"
  value = {
    schema_analyzer    = aws_lambda_function.schema_analyzer.function_name
    contract_generator = aws_lambda_function.contract_generator.function_name
    etl_patch_agent    = aws_lambda_function.etl_patch_agent.function_name
    staging_validator  = aws_lambda_function.staging_validator.function_name
  }
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "deployment_instructions" {
  description = "Next steps for deployment"
  value       = <<-EOT
    
    ✅ SchemaGuard AI Infrastructure Created Successfully!
    
    📋 Next Steps:
    1. Upload initial contract: 
       aws s3 cp contracts/contract_v1.json s3://${aws_s3_bucket.contracts.id}/
    
    2. Deploy Glue script: 
       aws s3 cp glue/etl_job.py s3://${aws_s3_bucket.scripts.id}/glue/
    
    3. Confirm SNS subscription email (check your inbox)
    
    4. Test with sample data: 
       aws s3 cp tests/sample-data-baseline.json s3://${aws_s3_bucket.raw.id}/data/
    
    📊 Monitoring:
    - Step Functions: https://console.aws.amazon.com/states/home?region=${var.aws_region}
    - CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}
    
    📚 Documentation:
    - Quick Start: See QUICKSTART.md
    - Architecture: See docs/architecture.md
    - Deployment: See DEPLOYMENT.md
    
  EOT
}
