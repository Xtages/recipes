locals {
  app_id = "${var.APP_ENV}-${substr(var.APP_NAME_HASH, 0, 12)}"
  tags = {
    application       = var.APP_NAME_HASH
    organization      = var.APP_ORG
    organization-hash = var.APP_ORG_HASH
    environment       = var.APP_ENV
  }


  staging = {
    host_header = ""
  }
  production = {
    host_header = var.HOST_HEADER
  }


  ecs_cluster_name = split("/", data.terraform_remote_state.customer_infra_ecs.outputs.xtages_ecs_cluster_id)[1]
  key_prefix = "tfstate/${var.aws_region}/${var.ENV}"

  xtages_backends = {
    development = {
      domain = "xtages.xyz"
      host_header = "${var.APP_ENV}-${substr(var.APP_NAME_HASH, 0, 12)}.xtages.xyz"
      bucket = "xtages-dev-tfstate"
      vpc_id = data.terraform_remote_state.xtages_vpc == [] ? "" : data.terraform_remote_state.xtages_vpc[0].outputs.vpc_id
      app_iam_roles_config = {
        bucket = "xtages-dev-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/iam-apps/terraform.tfstate"
        region = var.aws_region
      }
      ecs_config = {
        bucket = "xtages-dev-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/ecs-customer/${var.APP_ENV}/terraform.tfstate"
        region = var.aws_region
      }
      lbs_config = {
        bucket = "xtages-dev-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/lbs/terraform.tfstate"
        region = var.aws_region
      }
    }
    production = {
      domain = "xtages.dev"
      host_header =
      bucket = "xtages-tfstate"
      vpc_id = data.terraform_remote_state.xtages_infra == [] ? "" : data.terraform_remote_state.xtages_infra[0].outputs.vpc_id
      app_iam_roles_config = {
        bucket = "xtages-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/apps/iam"
        region = var.aws_region
      }
      ecs_config = {
        bucket = "xtages-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/ecs/${var.APP_ENV}/customers"
        region = var.aws_region
      }
      lbs_config = {
        bucket = "xtages-tfstate"
        key    = "tfstate/${var.aws_region}/${var.ENV}/lbs/lb-tfstate"
        region = var.aws_region
      }
    }
  }

  # to lower the desired count for staging
  approx_undeploy_time = timeadd(timestamp(), "65m")
  min_utc              = formatdate("m", local.approx_undeploy_time)
  hour_utc             = formatdate("h", local.approx_undeploy_time)
  day_utc              = formatdate("DD", local.approx_undeploy_time)
  month_utc            = formatdate("MM", local.approx_undeploy_time)
  year_utc             = formatdate("YYYY", local.approx_undeploy_time)
}
