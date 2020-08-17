################################################
################ Outputs
################################################

output "buildserver-private_dns" {
  value = aws_instance.buildserver.*.private_dns
}

output "buildserver-private_ip" {
  value = aws_instance.buildserver.*.private_ip
}

################################################
################ Vars
################################################

variable "buildserver_instancesize" {
  description = "instance type for bastion"
}

variable "buildserver_instancecount" {
  description = "number of bastion nodes"
}

variable "buildserver_hostname" {
  description = "hostname"
}

variable "buildserver_rootdisk_storage_type" {
  description = "root disk type"
}

variable "buildserver_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "buildserver_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  buildserver_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
}

################################################
################ DNS
################################################

resource "aws_route53_record" "buildserver" {
  count = var.buildserver_instancecount

  zone_id = module.management_common_base_network.dns_internal.zone_id
  name    = "${var.buildserver_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.management_common_base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.buildserver[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_buildserver" {
  count    = var.buildserver_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.management_common_base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "buildserver" {
  count = var.buildserver_instancecount

  subnet_id                   = module.management_common_base_network.subnet_management[count.index].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.buildserver_instancesize
  user_data                   = data.template_file.setup_buildserver[count.index].rendered
  key_name                    = module.management_common_base_security.ssh_key_pair_internalnode_id

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.buildserver_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.management_common_base_network.common_securitygroup.id,
    [ 
      aws_security_group.jenkins.id,
      aws_security_group.wmdeployer.id 
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.buildserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.buildserver_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}

resource "aws_volume_attachment" "buildserver" {
  count = var.buildserver_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.buildserver[count.index].id
  instance_id = aws_instance.buildserver[count.index].id
}

resource "aws_ebs_volume" "buildserver" {
  count = var.buildserver_instancecount

  availability_zone = module.management_common_base_network.subnet_management[count.index].availability_zone
  type              = var.buildserver_datadisk_storage_type
  size              = var.buildserver_datadisk_size_gb
  
  tags = merge(
    local.buildserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.buildserver_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}