variable "env" {
  default = "production"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "TAG" {
  description = "TAG version used for the task definition. This is available as a environment variable"
}

variable "APP_NAME_HASH" {
  description = "Application name. This value needs to be defined as an environment variable "
}

variable "APP_ENV" {
  description = "Environment where the application will be deploy. This values needs to be defined as an environment variable"
}

variable "APP_ORG" {
  description = "Organization that owns the app. This values needs to be defined as an environment variable"
}

variable "APP_ORG_HASH" {
  description = "Hash that identify the Organization"
}

variable "ecr_nginx_repo" {
  default = "xtages-nginx"
  description = "ECR repository that host our nginx version"
}

variable "nginx_version" {
  default = "1.18.0"
  description = "Nginx version that will be pulled from ECR nginx repo using that tag name"
}
