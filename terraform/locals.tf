locals {
  app_id = "${var.APP_ENV}-${substr(var.APP_NAME_HASH, 0, 12)}"
  tags = {
    application       = var.APP_NAME_HASH
    organization-hash = var.APP_ORG_HASH
    environment       = var.APP_ENV
  }


  app_env_vars = {
    staging = {
      host_header = ""
    }
    production = {
      host_header = var.HOST_HEADER
    }
  }


  ecs_cluster_name = split("/", data.terraform_remote_state.customer_infra_ecs.outputs.xtages_ecs_cluster_id)[1]
  key_prefix = "tfstate/${var.aws_region}/${var.ENV}"

  free_plan = {
    app_td_vcpu   = 512
    app_td_mem    = 512
    nginx_td_vcpu = 256
    nginx_td_mem  = 256
  }

  xtages_backends = {
    development = {
      domain = "xtages.xyz"
      bucket = "xtages-dev-tfstate"
      app_td_vcpu = 1792
      app_td_mem = 3072
      nginx_td_vcpu = 256
      nginx_td_mem = 256
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
      bucket = "xtages-tfstate"
      app_td_vcpu = 2048
      app_td_mem = 4096
      nginx_td_vcpu = 512
      nginx_td_mem = 512
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

}
