locals {
  app_id = "${var.APP_ENV}-${substr(var.APP_NAME_HASH, 0, 12)}"
  tags = {
    application       = var.APP_NAME_HASH,
    organization      = var.APP_ORG,
    organization-hash = var.APP_ORG_HASH
    environment       = var.APP_ENV
  }

  environment = {
    staging = {
      cluster_arn            = data.terraform_remote_state.customer_infra_ecs_staging.outputs.xtages_ecs_cluster_id
      ecs_iam_role           = data.terraform_remote_state.customer_infra_ecs_staging.outputs.ecs_service_role_arn
      capacity_provider_name = data.terraform_remote_state.customer_infra_ecs_staging.outputs.ecs_capacity_provider_name
    }
    production = {
      cluster_arn            = data.terraform_remote_state.customer_infra_ecs_production.outputs.xtages_ecs_cluster_id
      ecs_iam_role           = data.terraform_remote_state.customer_infra_ecs_production.outputs.ecs_service_role_arn
      capacity_provider_name = data.terraform_remote_state.customer_infra_ecs_production.outputs.ecs_capacity_provider_name
    }
  }

  staging_cluster_name = split("/", local.environment.staging.cluster_arn)[1]

  # to lower the desired count for staging
  approx_undeploy_time = timeadd(timestamp(), "65m")
  min_utc              = formatdate("m", local.approx_undeploy_time)
  hour_utc             = formatdate("h", local.approx_undeploy_time)
  day_utc              = formatdate("DD", local.approx_undeploy_time)
  month_utc            = formatdate("MM", local.approx_undeploy_time)
  year_utc             = formatdate("YYYY", local.approx_undeploy_time)
}

resource "aws_ecs_task_definition" "app_task_definition" {
  family                = local.app_id
  container_definitions = data.template_file.app_task_definition.rendered
  task_role_arn         = data.terraform_remote_state.apps_iam_roles.outputs.apps_iam_role_arn
  tags                  = local.tags
}

resource "aws_route53_record" "app_cname_record" {
  name            = "${local.app_id}.xtages.dev"
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.xtages_zone.zone_id
  ttl             = 60
  records         = [data.aws_lb.xtages_customers_lb.dns_name]
  allow_overwrite = true
}

resource "aws_lb_listener" "xtages_service_secure" {
  load_balancer_arn = data.aws_lb.xtages_customers_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.xtages_cert.id
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_certificate" "customer_cert_listener" {
  count           = var.CUSTOMER_DOMAIN != "" ? 1 : 0
  certificate_arn = data.aws_acm_certificate.customer_cer[0].arn
  listener_arn    = aws_lb_listener.xtages_service_secure.arn
}

resource "aws_lb_listener_rule" "xtages_listener_app_rule" {
  listener_arn = aws_lb_listener.xtages_service_secure.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.id
  }

  condition {
    host_header {
      values = compact(["${local.app_id}.xtages.dev", var.HOST_HEADER])
    }
  }

}

resource "aws_lb_listener" "app_service_lb_listener" {
  load_balancer_arn = data.aws_lb.xtages_customers_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name                 = local.app_id
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.xtages_infra.outputs.vpc_id
  deregistration_delay = 20
  tags                 = local.tags

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    matcher             = "200,301,302"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "xtages_app_service" {
  name                = var.APP_NAME_HASH
  cluster             = lookup(local.environment[var.APP_ENV], "cluster_arn")
  task_definition     = aws_ecs_task_definition.app_task_definition.arn
  desired_count       = 1
  iam_role            = lookup(local.environment[var.APP_ENV], "ecs_iam_role")
  tags                = local.tags
  scheduling_strategy = "REPLICA"

  capacity_provider_strategy {
    capacity_provider = lookup(local.environment[var.APP_ENV], "capacity_provider_name")
    weight            = 1
    base              = 0
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.id
    container_name   = "nginx"
    container_port   = 1800
  }
}
