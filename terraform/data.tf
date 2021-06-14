data "terraform_remote_state" "xtages_infra" {
  backend = "s3"
  config = {
    bucket = "xtages-tfstate"
    key    = "tfstate/us-east-1/production"
    region = "us-east-1"
  }
}

data "aws_route53_zone" "xtages_zone" {
  name         = "xtages.dev"
  private_zone = false
}

data "aws_lb" "xtages_customers_lb" {
  arn = data.terraform_remote_state.xtages_infra.outputs.xtages_customers_alb_arn
}

data "aws_acm_certificate" "xtages_cert" {
  domain   = "xtages.dev"
  statuses = ["ISSUED"]
}

data "aws_ecr_repository" "xtages_app_repo" {
  name = var.APP_NAME_HASH
}

data "template_file" "app_task_definition" {
  template = file("${path.root}/templates/application.json.tpl")
  vars = {
    REPOSITORY_URL = replace(data.aws_ecr_repository.xtages_app_repo.repository_url, "https://", "")
    TAG            = "${var.APP_ENV}-${var.TAG}"
    APP_NAME       = var.APP_NAME_HASH
  }
}
