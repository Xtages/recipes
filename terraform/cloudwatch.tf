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

resource "aws_appautoscaling_target" "ecs_staging_lower_capacity" {
  count = var.APP_ENV == "staging" ? 1 : 0
  max_capacity = 1
  min_capacity = 0
  resource_id = "service/xtages-customer-staging/${local.app_id}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

//resource "aws_appautoscaling_policy" "ecs_staging_lower_capacity_policy" {
//  count = var.APP_ENV == "staging" ? 1 : 0
//  name = "scale-down"
//  resource_id = aws_appautoscaling_target.ecs_staging_lower_capacity.resource_id
//  scalable_dimension = aws_appautoscaling_target.ecs_staging_lower_capacity.scalable_dimension
//  service_namespace = aws_appautoscaling_target.ecs_staging_lower_capacity.service_namespace
//
//  step_scaling_policy_configuration {
//    adjustment_type = "ChangeInCapacity"
//    cooldown = 60
//    metric_aggregation_type = "Maximum"
//
//    step_adjustment {
//      metric_interval_upper_bound = 0
//      scaling_adjustment = -1
//    }
//  }
//}

resource "aws_appautoscaling_scheduled_action" "dynamodb" {
  count = var.APP_ENV == "staging" ? 1 : 0
  name               = local.app_id
  service_namespace  = aws_appautoscaling_target.ecs_staging_lower_capacity.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_staging_lower_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_staging_lower_capacity.scalable_dimension
  schedule           = "cron(5 0 ${local.day_utc} ${local.month_utc} ? ${local.year_utc}"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}
