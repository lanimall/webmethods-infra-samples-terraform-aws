
##########################
# NAT GATEWAYS
##########################

locals {
  natgw_subnets = module.common_network.subnet_dmz
}

// create eip for nat
resource "aws_eip" "NATGW" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))
  vpc   = true

  tags = {
    "Name" = "${module.global_common_base.name_prefix_long}-natgw${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
  }
}

resource "aws_nat_gateway" "NATGW" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))
  allocation_id = element(aws_eip.NATGW.*.id, count.index)
  subnet_id     = element(local.natgw_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-natgw${count.index + 1}-${local.natinstance_subnets[count.index].availability_zone}"
      "az"   = local.natinstance_subnets[count.index].availability_zone
    },
  )
}

resource "aws_route" "private_nat_gateway" {
  count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.NATGW.*.id, count.index)

  timeouts {
    create = "5m"
  }
}
