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
