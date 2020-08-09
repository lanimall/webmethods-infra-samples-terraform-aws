output "dns_main_external_apex" {
  value = local.dns_main_external_apex
}

output "dns_main_external_zoneid" {
  value = aws_route53_zone.main-external.id
}

locals {
  dns_main_external_apex = substr(
    aws_route53_zone.main-external.name,
    0,
    length(aws_route53_zone.main-external.name) - 1,
  )
}

resource "aws_route53_zone" "main-external" {
  name    = var.resources_external_dns_apex
  comment = "Main Public DNS for demo project [${var.application_code}] - Managed by Terraform"

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-Main External Public DNS"
    },
  )
}