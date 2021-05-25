locals {
  app_id = "${var.APP_NAME}-${var.APP_ORG}"
  tags = {
    application  = var.APP_NAME,
    organization = var.APP_ORG,
    environment  = var.APP_ENV
  }
}

resource "aws_ecr_repository" "deploy_app_repo" {
  name                 = "${var.APP_ORG}/${var.APP_NAME}-${var.APP_ENV}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "app_task_definition" {
  family                = local.app_id
  container_definitions = data.template_file.app_task_definition.rendered
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

resource "aws_lb_listener_rule" "xtages_listener_app_rule" {
  listener_arn = aws_lb_listener.xtages_service_secure.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.id
  }

  condition {
    host_header {
      values = ["${local.app_id}.xtages.dev"]
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
  name     = "${local.app_id}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.xtages_infra.outputs.vpc_id
  tags     = local.tags

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
  name            = local.app_id
  cluster         = data.terraform_remote_state.xtages_infra.outputs.xtages_ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  desired_count   = 1
  iam_role        = data.terraform_remote_state.xtages_infra.outputs.ecs_service_role_arn
  tags            = local.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.id
    container_name   = var.APP_NAME
    container_port   = 3000
  }
}
