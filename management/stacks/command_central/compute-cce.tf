################################################
################ Outputs
################################################

output "commandcentral-private_dns" {
  value = aws_instance.commandcentral.*.private_dns
}

output "commandcentral-private_ip" {
  value = aws_instance.commandcentral.*.private_ip
}

################################################
################ Vars
################################################

variable "commandcentral_instancesize" {
  description = "instance type for bastion"
}

variable "commandcentral_instancecount" {
  description = "number of bastion nodes"
}

variable "commandcentral_hostname" {
  description = "hostname"
}

variable "commandcentral_rootdisk_storage_type" {
  description = "root disk type"
}

variable "commandcentral_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "commandcentral_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  commandcentral_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
}

################################################
################ DNS
################################################

resource "aws_route53_record" "commandcentral" {
  count = var.commandcentral_instancecount

  zone_id = module.management_common_base_network.dns_internal.zone_id
  name    = "${var.commandcentral_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.management_common_base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.commandcentral[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_commandcentral" {
  count    = var.commandcentral_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.management_common_base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "commandcentral" {
  count = var.commandcentral_instancecount

  subnet_id                   = module.management_common_base_network.subnet_management[count.index].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.commandcentral_instancesize
  user_data                   = data.template_file.setup_commandcentral[count.index].rendered
  key_name                    = module.management_common_base_security.ssh_key_pair_internalnode_id
  
  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type = var.commandcentral_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.management_common_base_network.common_securitygroup.id,
    [ 
      aws_security_group.webmethods-commandcentral.id 
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.commandcentral_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.commandcentral_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}

resource "aws_volume_attachment" "commandcentral" {
  count = var.commandcentral_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.commandcentral[count.index].id
  instance_id = aws_instance.commandcentral[count.index].id
}

resource "aws_ebs_volume" "commandcentral" {
  count = var.commandcentral_instancecount

  availability_zone = module.management_common_base_network.subnet_management[count.index].availability_zone
  type              = var.commandcentral_datadisk_storage_type
  size              = var.commandcentral_datadisk_size_gb
  
  tags = merge(
    local.commandcentral_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.commandcentral_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}