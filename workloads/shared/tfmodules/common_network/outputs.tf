
output "network" {
  value = data.aws_vpc.main
}

output "subnet_dmz" {
  value = data.aws_subnet.dmz
}

output "subnet_web" {
  value = data.aws_subnet.web
}

output "subnet_apps" {
  value = data.aws_subnet.apps
}

output "subnet_data" {
  value = data.aws_subnet.data
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

output "common_network_securitygroup" {
  value = local.base_aws_security_group_commoninternal
}

output "main_public_alb_dns_name" {
  value = data.aws_lb.main-public-alb.dns_name
}

output "main_public_alb_id" {
  value = data.aws_lb.main-public-alb.id
}

output "main_public_alb_http_id" {
  value = data.aws_lb_listener.main-public-alb-http.id
}

output "main_public_alb_https_id" {
  value = data.aws_lb_listener.main-public-alb-https.id
}