############# certificates ############

output "aws_acm_certificate_mainlb_arn" {
  value = aws_acm_certificate.mainlb.arn
}

resource "aws_acm_certificate" "mainlb" {
  private_key       = file(var.ssl_cert_mainlb_key_path)
  certificate_body  = file(var.ssl_cert_mainlb_pub_path)
  certificate_chain = file(var.ssl_cert_mainlb_ca_path)

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-mainlb"
    },
  )
}