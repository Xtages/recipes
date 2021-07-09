data "terraform_remote_state" "xtages_infra" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "apps_iam_roles" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production/apps/iam"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "customer_infra_ecs_staging" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production/ecs/staging/customers"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "customer_infra_ecs_production" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production/ecs/production/customers"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "xtages_infra_lbs" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production/lbs/lb-tfstate"
    region = "us-east-1"
  }
}

data "aws_route53_zone" "xtages_zone" {
  name         = "xtages.dev"
  private_zone = false
}

data "aws_lb" "xtages_customers_lb" {
  arn = data.terraform_remote_state.xtages_infra_lbs.outputs.xtages_customers_alb_arn
}

data "aws_acm_certificate" "xtages_cert" {
  domain   = "xtages.dev"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "customer_cer" {
  count    = var.CUSTOMER_DOMAIN != "" ? 1 : 0
  domain   = var.CUSTOMER_DOMAIN
  statuses = ["ISSUED"]
}

data "aws_ecr_repository" "xtages_app_repo" {
  name = var.APP_NAME_HASH
}

data "aws_ecr_repository" "xtages_nginx_repo" {
  name = var.ecr_nginx_repo
}

data "template_file" "app_task_definition" {
  template = file("${path.root}/templates/application.json.tpl")
  vars = {
    APP_REPOSITORY_URL   = replace(data.aws_ecr_repository.xtages_app_repo.repository_url, "https://", "")
    APP_TAG              = "${var.APP_ENV}-${var.TAG}"
    APP_NAME             = var.APP_NAME_HASH
    NGINX_REPOSITORY_URL = replace(data.aws_ecr_repository.xtages_nginx_repo.repository_url, "https://", "")
    NGINX_TAG            = var.nginx_version
    APP_ORG_HASH         = var.APP_ORG_HASH
    APP_ENV              = var.APP_ENV
    APP_BUILD_ID         = var.APP_BUILD_ID
  }
}
