
################################################
################ Load Balancer
################################################

locals {
  apigateway_runtime-lb-name        = "apigw"
  apigateway_runtime-lb-protocol    = "HTTP"
  apigateway_runtime-lb-port        = 5555
  apigateway_runtime-lb-target-type = "instance"

  apigateway_ui-lb-name        = "apigw-ui"
  apigateway_ui-lb-protocol    = "HTTP"
  apigateway_ui-lb-port        = 9072
  apigateway_ui-lb-target-type = "instance"
}

resource "random_id" "apigateway_ui-lb" {
  keepers = {
    protocol    = local.apigateway_ui-lb-protocol
    port        = local.apigateway_ui-lb-port
    vpc_id      = module.common_network.network.id
    target_type = local.apigateway_ui-lb-target-type
  }
  byte_length = 2
}

resource "random_id" "apigateway_runtime-lb" {
  keepers = {
    protocol    = local.apigateway_runtime-lb-protocol
    port        = local.apigateway_runtime-lb-port
    vpc_id      = module.common_network.network.id
    target_type = local.apigateway_runtime-lb-target-type
  }
  byte_length = 2
}

################ API Gateway UI

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway_ui" {
  name                 = "${module.global_common_base.name_prefix_short}-${local.apigateway_ui-lb-name}-${random_id.apigateway_ui-lb.hex}"
  port                 = random_id.apigateway_ui-lb.keepers.port
  protocol             = random_id.apigateway_ui-lb.keepers.protocol
  vpc_id               = random_id.apigateway_ui-lb.keepers.vpc_id
  target_type          = random_id.apigateway_ui-lb.keepers.target_type

  slow_start           = 100
  deregistration_delay = 300

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/apigatewayui/login"
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
      "Name" = "${module.global_common_base.name_prefix_long}-${local.apigateway_ui-lb-name}-${random_id.apigateway_ui-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apigateway_ui" {
  count = var.apigateway_instancecount

  target_group_arn = aws_lb_target_group.apigateway_ui.arn
  target_id        = aws_instance.apigateway[count.index].id
}

resource "aws_alb_listener_rule" "apigateway_ui" {
  listener_arn = module.common_network.main_public_alb_https_id

  action {
    target_group_arn = aws_lb_target_group.apigateway_ui.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apigateway_ui_external_host_name}.${module.common_network.dns_external_apex}"]
    }
  }
}

################ API Gateway Runtime

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway_runtime" {
  name                 = "${module.global_common_base.name_prefix_short}-${local.apigateway_runtime-lb-name}-${random_id.apigateway_runtime-lb.hex}"
  port                 = random_id.apigateway_runtime-lb.keepers.port
  protocol             = random_id.apigateway_runtime-lb.keepers.protocol
  vpc_id               = random_id.apigateway_runtime-lb.keepers.vpc_id
  target_type          = random_id.apigateway_runtime-lb.keepers.target_type

  slow_start           = 100
  deregistration_delay = 300

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/invoke/wm.server/ping"
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
      "Name" = "${module.global_common_base.name_prefix_short}-${local.apigateway_runtime-lb-name}-${random_id.apigateway_runtime-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apigateway_runtime" {
  count = var.apigateway_instancecount

  target_group_arn = aws_lb_target_group.apigateway_runtime.arn
  target_id        = aws_instance.apigateway[count.index].id
}

resource "aws_alb_listener_rule" "apigateway_runtime" {
  listener_arn = module.common_network.main_public_alb_https_id

  action {
    target_group_arn = aws_lb_target_group.apigateway_runtime.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apigateway_runtime_external_host_name}.${module.common_network.dns_external_apex}"]
    }
  }
}