resource "aws_cloudwatch_log_metric_filter" "nginx_bytes_sent" {
  name           = "MyAppAccessCount"
  pattern        = "{$$.http_user_agent != \"ELB-HealthChecker*\"}"
  log_group_name = aws_cloudwatch_log_group.app_ecs_log_group.name

  metric_transformation {
    name      = "Nginx_bytes_sent"
    namespace = var.APP_NAME_HASH
    value     = "$$.body_bytes_sent"
    unit      = "Bytes"

    dimensions = {
      organization = var.APP_ORG_HASH
      application  = var.APP_NAME_HASH
      environment  = var.env
    }
  }

}

resource "aws_cloudwatch_log_group" "app_ecs_log_group" {
  name = "/ecs/${var.APP_NAME_HASH}"
  tags = local.tags
}
