variable "env" {
  default = "production"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "TAG" {
  description = "TAG version used for the task definition. This is available as a environment variable"
}

variable "APP_NAME" {
  description = "Application name. This value needs to be defined as an environment variable "
}

//export TF_VAR_ORG="${XTAGES_ORG}"
variable "APP_ENV" {
  description = "Environment where the application will be deploy. This values needs to be defined as an environment variable"
}

variable "APP_ORG" {
  description = "Organization that owns the app. This values needs to be defined as an environment variable"
}
