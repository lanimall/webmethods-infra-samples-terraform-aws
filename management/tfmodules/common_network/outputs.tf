
output "network" {
  value = data.aws_vpc.main
}

output "subnet_dmz" {
  value = data.aws_subnet.dmz
}

output "subnet_management" {
  value = data.aws_subnet.mgt
}

output "dns_internal" {
  value = data.aws_route53_zone.internal
}

output "dns_external" {
  value = data.aws_route53_zone.external
}

output "dns_internal_apex" {
  value = local.dns_internal_apex
}

output "dns_external_apex" {
  value = local.dns_external_apex
}

output "network_az_mapping" {
  value = local.base_availability_zones_mapping
}

output "common_security" {
  value = local.base_aws_security_group_commoninternal
}