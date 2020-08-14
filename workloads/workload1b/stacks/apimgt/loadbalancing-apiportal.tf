
################################################
################ Load Balancer
################################################

locals {
  apiportal-lb-name        = "apiportal"
  apiportal-lb-protocol    = "HTTP"
  apiportal-lb-port        = 18101
  apiportal-lb-target-type = "instance"
}

resource "random_id" "apiportal-lb" {
  keepers = {
    protocol    = local.apiportal-lb-protocol
    port        = local.apiportal-lb-port
    vpc_id      = module.common_network.network.id
    target_type = local.apiportal-lb-target-type
  }
  byte_length = 2
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apiportal" {
  name                 = "${module.global_common_base.name_prefix_short}-${local.apiportal-lb-name}-${random_id.apiportal-lb.hex}"
  port                 = random_id.apiportal-lb.keepers.port
  protocol             = random_id.apiportal-lb.keepers.protocol
  vpc_id               = random_id.apiportal-lb.keepers.vpc_id
  target_type          = random_id.apiportal-lb.keepers.target_type

  slow_start           = 120
  deregistration_delay = 120

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${local.apiportal-lb-name}-${random_id.apiportal-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apiportal" {
  count = var.apiportal_instancecount

  target_group_arn = aws_lb_target_group.apiportal.arn
  target_id        = aws_instance.apiportal[count.index].id
}

resource "aws_alb_listener_rule" "apiportal" {
  listener_arn = module.common_network.main_public_alb_https_id

  action {
    target_group_arn = aws_lb_target_group.apiportal.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apiportal_external_host_name}-${module.global_common_base.workload_name_clean}.${module.common_network.dns_external_apex}"]
    }
  }
}