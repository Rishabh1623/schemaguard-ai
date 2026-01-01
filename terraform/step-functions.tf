# Step Functions State Machine for agent orchestration

resource "aws_sfn_state_machine" "schemaguard_orchestrator" {
  name     = "${local.resource_prefix}-orchestrator"
  role_arn = aws_iam_role.step_functions.arn

  definition = templatefile("${path.module}/../step-functions/schemaguard-state-machine.json", {
    schema_analyzer_arn     = aws_lambda_function.schema_analyzer.arn
    contract_generator_arn  = aws_lambda_function.contract_generator.arn
    etl_patch_agent_arn     = aws_lambda_function.etl_patch_agent.arn
    staging_validator_arn   = aws_lambda_function.staging_validator.arn
    glue_job_name           = aws_glue_job.etl_job.name
    sns_topic_arn           = aws_sns_topic.schema_drift_alerts.arn
    execution_state_table   = aws_dynamodb_table.execution_state.name
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Orchestrator"
    }
  )
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/vendedlogs/states/${local.resource_prefix}-orchestrator"
  retention_in_days = 30

  tags = local.common_tags
}

# EventBridge Rule to trigger Step Functions on S3 events
resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "${local.resource_prefix}-s3-object-created"
  description = "Trigger SchemaGuard orchestrator when new data lands in S3"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.raw.id]
      }
      object = {
        key = [{
          prefix = "data/"
        }]
      }
    }
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "step_functions" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "TriggerSchemaGuardOrchestrator"
  arn       = aws_sfn_state_machine.schemaguard_orchestrator.arn
  role_arn  = aws_iam_role.eventbridge.arn

  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
      time   = "$.time"
    }

    input_template = <<EOF
{
  "s3_bucket": <bucket>,
  "s3_key": <key>,
  "event_time": <time>,
  "execution_id": "$${aws:eventId}"
}
EOF
  }
}
