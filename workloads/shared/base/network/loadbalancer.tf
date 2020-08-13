##########################
# Load balancers
##########################

output "main_public_alb_dns_name" {
  value = aws_lb.main-public-alb.dns_name
}

output "main_public_alb_id" {
  value = aws_lb.main-public-alb.id
}

output "main_public_alb_http_id" {
  value = aws_lb_listener.main-public-alb-http.id
}

output "main_public_alb_https_id" {
  value = aws_lb_listener.main-public-alb-https.id
}

####### Main public app traffic

resource "aws_route53_record" "main-alb-wildcard" {
  zone_id = aws_route53_zone.main-external.zone_id
  name    = "*.${aws_route53_zone.main-external.name}"
  type    = "A"

  alias {
    name                   = aws_lb.main-public-alb.dns_name
    zone_id                = aws_lb.main-public-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "main-public-alb" {
  name               = "${module.global_common_base.name_prefix_short}main"
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.dmz.*.id
  security_groups = [
    aws_security_group.main-public-alb.id,
  ]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  enable_http2                     = true
  idle_timeout                     = 60

  /*
  access_logs {
    bucket  = "${aws_s3_bucket.webm-ext-app-lb-logs.bucket}"
    prefix  = "main-public"
    enabled = true
  }
  */

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-main-public-alb"
    },
  )
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

resource "aws_lb_listener" "main-public-alb-http" {
  load_balancer_arn = aws_lb.main-public-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "main-public-alb-https" {
  load_balancer_arn = aws_lb.main-public-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.mainlb.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Illegal Access"
      status_code  = "503"
    }
  }
}