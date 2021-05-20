data "terraform_remote_state" "xtages_customer_backend" {
  backend = "s3"
  config = {
    bucket  = "xtages-tfstate-customers"
    key     = "tfstate/us-east-1/production/${var.APP_ORG}/${var.APP_ENV}/app/${var.APP_NAME}"
    region  = "us-east-1"
    encrypt = true
  }
}
