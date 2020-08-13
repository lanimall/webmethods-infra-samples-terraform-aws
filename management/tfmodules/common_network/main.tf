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
  base_subnet_shortname_management=data.terraform_remote_state.base_network.outputs.subnet_shortname_management
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

###################### Reference to the various networks

##### DMZ subnets ######

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

data "aws_subnet" "mgt" {
  count = length(local.subnet_mgt_ids_sorted_by_az)
  id    = element(local.subnet_mgt_ids_sorted_by_az, count.index)
}