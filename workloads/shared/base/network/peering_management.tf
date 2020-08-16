
module "management_network" {
  source = "../../../../management/tfmodules/common_network"
  s3_bucket_name = "softwareag-devops-tfstates"
  s3_bucket_region = "us-east-1"
  provider_name = "aws"
  project_name = "webmethods_infra_samples"
  environment_level = var.environment_level
  workload_name = "management"
}

## we are in same account so using the current account
resource "aws_vpc_peering_connection" "peer_management_plane" {
  vpc_id        = aws_vpc.main.id
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = module.management_network.network.id
  auto_accept = true
}

resource "aws_vpc_peering_connection_options" "peer_management_plane" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_management_plane.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

#################################
# Peering routes to the private route
#################################

resource "aws_route" "peering" {
  count  = length(split(",", var.availability_zones_mapping[var.cloud_region]))

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = module.management_network.network.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_management_plane.id

  timeouts {
    create = "5m"
  }
}

resource "aws_security_group_rule" "management_plane_ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [
    module.management_network.network.cidr_block
  ]
  security_group_id = aws_security_group.common-internal.id
}

resource "aws_security_group_rule" "management_plane_egress_cce" {
  type              = "egress"
  from_port   = 8090
  to_port     = 8093
  protocol    = "tcp"
  cidr_blocks       = [
    module.management_network.network.cidr_block
  ]
  security_group_id = aws_security_group.common-internal.id
}