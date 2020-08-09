

################################################
################ Custom DNS to the other env
################################################

//Create the internal DNS.
resource "aws_route53_zone" "peered_internal" {
  name    = "clouddemo.saggov.com"
  comment = "Internal DNS to Docker Swarm in peered VPC"
  vpc {
    vpc_id = aws_vpc.main.id
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-peered-internal"
    },
  )
}

resource "aws_route53_record" "nginx" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "nginx.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.1.235"
  ]
}

resource "aws_route53_record" "peered_internal_wildcard" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "*.clouddemo.saggov.com"
  type    = "A"

  alias {
    name                   = aws_lb.main-public-alb.dns_name
    zone_id                = aws_lb.main-public-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "docker_swarm" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "*.apis.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.111",
    //"172.30.2.112",
    //"172.30.2.186",
    //"172.30.2.48"
  ]
}

resource "aws_route53_record" "docker_swarm_apis" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "*.sag_microservice_demo.apis.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.111",
    //"172.30.2.112",
    //"172.30.2.186",
    //"172.30.2.48"
  ]
}

resource "aws_route53_record" "docker_swarm_manager" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "docker_swarm_manager.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.111"
  ]
}

resource "aws_route53_record" "docker_swarm_worker1" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "docker_swarm_worker1.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.112"
  ]
}

resource "aws_route53_record" "docker_swarm_worker2" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "docker_swarm_worker2.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.186"
  ]
}

resource "aws_route53_record" "docker_swarm_worker3" {
  zone_id = aws_route53_zone.peered_internal.zone_id
  name    = "docker_swarm_worker3.clouddemo.saggov.com"
  type    = "A"
  ttl     = 300
  records = [
    "172.30.2.48"
  ]
}