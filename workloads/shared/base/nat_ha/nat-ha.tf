resource "aws_autoscaling_group" "natinstance" {
    count  = length(split(",", module.common_network.network_az_mapping[var.cloud_region]))

    name_prefix  = "${module.global_common_base.name_prefix_short}-nat"
    desired_capacity   = 1
    max_size           = 1
    min_size           = 1
    availability_zones = [ local.natinstance_subnets[count.index].availability_zone ]

    launch_template {
        id      = aws_launch_template.natinstance[count.index].id
        version = aws_launch_template.natinstance[count.index].latest_version
    }
}