###################### variables from base network

data "terraform_remote_state" "base_network" {
    backend = "s3"
    config = {
      bucket = var.s3_bucket_name
      key    = join(
                "/",
                [
                  var.project_name,
                  var.provider_name,
                  var.workload_name,
                  var.environment_level,
                  "base",
                  "network.tfstate"
                ]
              )
      region = var.s3_bucket_region
    }
}

locals {
  base_vpc_id = data.terraform_remote_state.base_network.outputs.vpc_id
  base_availability_zones_mapping = data.terraform_remote_state.base_network.outputs.availability_zones_mapping
  base_aws_security_group_commoninternal = data.terraform_remote_state.base_network.outputs.aws_security_group_commoninternal
  base_dns_main_internal_zoneid=data.terraform_remote_state.base_network.outputs.dns_main_internal_zoneid
  base_dns_main_internal_apex=data.terraform_remote_state.base_network.outputs.dns_main_internal_apex
  base_dns_main_external_zoneid=data.terraform_remote_state.base_network.outputs.dns_main_external_zoneid
  base_dns_main_external_apex=data.terraform_remote_state.base_network.outputs.dns_main_external_apex
  base_subnet_shortname_dmz=data.terraform_remote_state.base_network.outputs.subnet_shortname_dmz
  base_subnet_shortname_web=data.terraform_remote_state.base_network.outputs.subnet_shortname_web
  base_subnet_shortname_apps=data.terraform_remote_state.base_network.outputs.subnet_shortname_apps
  base_subnet_shortname_data=data.terraform_remote_state.base_network.outputs.subnet_shortname_data
  base_subnet_shortname_management=data.terraform_remote_state.base_network.outputs.subnet_shortname_management
  base_main_public_alb_dns_name=data.terraform_remote_state.base_network.outputs.main_public_alb_dns_name
  base_main_public_alb_id=data.terraform_remote_state.base_network.outputs.main_public_alb_id
  base_main_public_alb_http_id=data.terraform_remote_state.base_network.outputs.main_public_alb_http_id
  base_main_public_alb_https_id=data.terraform_remote_state.base_network.outputs.main_public_alb_https_id
}

###################### get the VPC from ID

data "aws_vpc" "main" {
  id = local.base_vpc_id
}

###################### Reference to the internal DNS.

data "aws_route53_zone" "external" {
  zone_id = local.base_dns_main_external_zoneid
}

data "aws_route53_zone" "internal" {
  zone_id = local.base_dns_main_internal_zoneid
}

locals {
  dns_external_apex = substr(
    data.aws_route53_zone.external.name,
    0,
    length(data.aws_route53_zone.external.name) - 1,
  )
  dns_internal_apex = substr(
    data.aws_route53_zone.internal.name,
    0,
    length(data.aws_route53_zone.internal.name) - 1,
  )
}

###################### Reference to the public load balancer listener.

data "aws_lb" "main-public-alb" {
  arn = local.base_main_public_alb_id
}

data "aws_lb_listener" "main-public-alb-http" {
  arn = local.base_main_public_alb_http_id
}

data "aws_lb_listener" "main-public-alb-https" {
  arn = local.base_main_public_alb_https_id
}

###################### Reference to the various networks

##### dmz subnets ######

data "aws_subnet_ids" "dmz" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_dmz
  }
}

data "aws_subnet" "dmz_unsorted" {
  count = length(data.aws_subnet_ids.dmz.ids)
  id    = tolist(data.aws_subnet_ids.dmz.ids)[count.index]
}

##### web subnets ######

data "aws_subnet_ids" "web" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_web
  }
}

data "aws_subnet" "web_unsorted" {
  count = length(data.aws_subnet_ids.web.ids)
  id    = tolist(data.aws_subnet_ids.web.ids)[count.index]
}

##### apps subnets ######

data "aws_subnet_ids" "apps" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_apps
  }
}

data "aws_subnet" "apps_unsorted" {
  count = length(data.aws_subnet_ids.apps.ids)
  id    = tolist(data.aws_subnet_ids.apps.ids)[count.index]
}

##### data subnets ######

data "aws_subnet_ids" "data" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_data
  }
}

data "aws_subnet" "data_unsorted" {
  count = length(data.aws_subnet_ids.data.ids)
  id    = tolist(data.aws_subnet_ids.data.ids)[count.index]
}

##### Management subnets ######

data "aws_subnet_ids" "mgt" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_management
  }
}

data "aws_subnet" "mgt_unsorted" {
  count = length(data.aws_subnet_ids.mgt.ids)
  id    = tolist(data.aws_subnet_ids.mgt.ids)[count.index]
}

##### Sort subnets by AZ for predictable ordering ######

locals {
  subnet_dmz_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.dmz_unsorted.*.availability_zone,
      data.aws_subnet.dmz_unsorted.*.id,
    ),
  )
  subnet_web_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.web_unsorted.*.availability_zone,
      data.aws_subnet.web_unsorted.*.id,
    ),
  )
  subnet_apps_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.apps_unsorted.*.availability_zone,
      data.aws_subnet.apps_unsorted.*.id,
    ),
  )
  subnet_data_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.data_unsorted.*.availability_zone,
      data.aws_subnet.data_unsorted.*.id,
    ),
  )
  subnet_mgt_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.mgt_unsorted.*.availability_zone,
      data.aws_subnet.mgt_unsorted.*.id,
    ),
  )
}

data "aws_subnet" "dmz" {
  count = length(local.subnet_dmz_ids_sorted_by_az)
  id    = element(local.subnet_dmz_ids_sorted_by_az, count.index)
}

data "aws_subnet" "web" {
  count = length(local.subnet_web_ids_sorted_by_az)
  id    = element(local.subnet_web_ids_sorted_by_az, count.index)
}

data "aws_subnet" "apps" {
  count = length(local.subnet_apps_ids_sorted_by_az)
  id    = element(local.subnet_apps_ids_sorted_by_az, count.index)
}

data "aws_subnet" "data" {
  count = length(local.subnet_data_ids_sorted_by_az)
  id    = element(local.subnet_data_ids_sorted_by_az, count.index)
}

data "aws_subnet" "mgt" {
  count = length(local.subnet_mgt_ids_sorted_by_az)
  id    = element(local.subnet_mgt_ids_sorted_by_az, count.index)
}