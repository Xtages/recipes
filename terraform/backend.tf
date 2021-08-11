terraform {
  backend "s3" {
    bucket  = var.BACKEND_BUCKET
    key     = "tfstate/us-east-1/${var.ENV}/${var.APP_ORG_HASH}/${var.APP_ENV}/app/${var.APP_NAME_HASH}"
    region  = "us-east-1"
    encrypt = true
  }
}
