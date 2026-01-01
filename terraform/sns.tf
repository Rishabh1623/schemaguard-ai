# SNS topics for notifications

resource "aws_sns_topic" "schema_drift_alerts" {
  name              = "${local.resource_prefix}-schema-drift-alerts"
  display_name      = "SchemaGuard AI Schema Drift Alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = "SchemaGuard Alerts"
    }
  )
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.schema_drift_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "schema_drift_alerts" {
  arn = aws_sns_topic.schema_drift_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.schema_drift_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
}
