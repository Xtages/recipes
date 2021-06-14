terraform {
  backend "s3" {
    bucket  = "xtages-tfstate-customers"
    key     = "tfstate/us-east-1/production/${var.APP_ORG_HASH}/${var.APP_ENV}/app/${var.APP_NAME_HASH}"
    region  = "us-east-1"
    encrypt = true
  }
}
