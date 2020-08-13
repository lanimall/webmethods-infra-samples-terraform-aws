################################################
################ Outputs
################################################

output "terracotta-private_dns" {
  value = aws_instance.terracotta.*.private_dns
}

output "terracotta-private_ip" {
  value = aws_instance.terracotta.*.private_ip
}

################################################
################ Vars
################################################

variable "terracotta_instancesize" {
  description = "instance type for bastion"
}

variable "terracotta_instancecount" {
  description = "number of bastion nodes"
}

variable "terracotta_hostname" {
  description = "hostname"
}

variable "terracotta_rootdisk_storage_type" {
  description = "root disk type"
}

variable "terracotta_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "terracotta_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  terracotta_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  terracotta_subnets = module.common_network.subnet_data
}

################################################
################ DNS
################################################

resource "aws_route53_record" "terracotta" {
  count = var.terracotta_instancecount

  zone_id = module.common_network.dns_internal.zone_id
  name    = "${var.terracotta_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.common_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.terracotta[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_terracotta" {
  count    = var.terracotta_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.common_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "terracotta" {
  count = var.terracotta_instancecount

  subnet_id                   = local.terracotta_subnets[count.index%length(local.terracotta_subnets)].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.terracotta_instancesize
  user_data                   = data.template_file.setup_terracotta[count.index].rendered
  key_name                    = module.common_security.ssh_key_pair_internalnode_id
  associate_public_ip_address = "true"

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.terracotta_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.common_network.common_network_securitygroup,
    [ 
      aws_security_group.apigateway_terracotta.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.terracotta_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.terracotta_hostname}${count.index + 1}-${local.terracotta_subnets[count.index%length(local.terracotta_subnets)].availability_zone}"
      "az"   = local.terracotta_subnets[count.index%length(local.terracotta_subnets)].availability_zone
    },
  )
}

resource "aws_volume_attachment" "terracotta" {
  count = var.terracotta_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.terracotta[count.index].id
  instance_id = aws_instance.terracotta[count.index].id
}

resource "aws_ebs_volume" "terracotta" {
  count = var.terracotta_instancecount

  availability_zone = local.terracotta_subnets[count.index%length(local.terracotta_subnets)].availability_zone
  type              = var.terracotta_datadisk_storage_type
  size              = var.terracotta_datadisk_size_gb
  
  tags = merge(
    local.terracotta_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.terracotta_hostname}${count.index + 1}-${local.terracotta_subnets[count.index%length(local.terracotta_subnets)].availability_zone}"
      "az"   = local.terracotta_subnets[count.index%length(local.terracotta_subnets)].availability_zone
    },
  )
}