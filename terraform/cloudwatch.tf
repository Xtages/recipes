resource "aws_cloudwatch_log_metric_filter" "nginx_bytes_sent" {
  name           = "nginx_app_filter"
  pattern        = "{$.http_user_agent != \"ELB-HealthChecker*\"}"
  log_group_name = aws_cloudwatch_log_group.app_ecs_log_group.name

  metric_transformation {
    name      = "nginx_bytes_sent"
    namespace = var.APP_NAME_HASH
    value     = "$.body_bytes_sent"
    unit      = "Bytes"

    dimensions = {
      organization = "$.organization"
      application  = "$.project"
      environment  = "$.environment"
    }
  }

}

resource "aws_cloudwatch_log_group" "app_ecs_log_group" {
  name = "/ecs/${var.APP_NAME_HASH}-${var.APP_ENV}"
  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "lower_task_staging_after_1h" {
  count = var.APP_ENV != "staging" ? 1 : 0
  name = "lower-task-${var.APP_NAME_HASH}-staging"
//  schedule_expression = "cron(0 1 ${local.day_utc} ${local.month_utc} ? ${local.year_utc}"
  schedule_expression = "cron(5 0 ${local.day_utc} ${local.month_utc} ? ${local.year_utc}"
  description = "lower task count for application to zero"
  tags = local.tags
}

resource "aws_cloudwatch_event_target" "ecs_lower_task_staging" {
  count = var.APP_ENV != "staging" ? 1 : 0
  arn = local.cluster_arn["staging"]
  rule = aws_cloudwatch_event_rule.lower_task_staging_after_1h.name
  role_arn = "arn:aws:iam::606626603369:role/CloudWatchEventTargetEcsRole"

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.app_task_definition.arn
    task_count = 0
  }
}
