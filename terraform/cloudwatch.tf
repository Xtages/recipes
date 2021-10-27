resource "aws_cloudwatch_log_metric_filter" "nginx_bytes_sent" {
  name           = "nginx_app_filter"
  pattern        = "{$.http_user_agent != \"ELB-HealthChecker*\"}"
  log_group_name = aws_cloudwatch_log_group.app_ecs_log_group.name

  metric_transformation {
    name      = "nginx_bytes_sent"
    namespace = "customer-metrics"
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
