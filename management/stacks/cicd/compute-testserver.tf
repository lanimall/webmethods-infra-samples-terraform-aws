################################################
################ Outputs
################################################

output "testserver-private_dns" {
  value = aws_instance.testserver.*.private_dns
}

output "testserver-private_ip" {
  value = aws_instance.testserver.*.private_ip
}

################################################
################ Vars
################################################

variable "testserver_instancesize" {
  description = "instance type for bastion"
}

variable "testserver_instancecount" {
  description = "number of bastion nodes"
}

variable "testserver_hostname" {
  description = "hostname"
}

variable "testserver_rootdisk_storage_type" {
  description = "root disk type"
}

variable "testserver_datadisk_storage_type" {
  description = "app/data disk type"
}

variable "testserver_datadisk_size_gb" {
  description = "app/data disk size (gb)"
}

locals {
  testserver_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
}

################################################
################ DNS
################################################

resource "aws_route53_record" "testserver" {
  count = var.testserver_instancecount

  zone_id = module.management_common_base_network.dns_internal.zone_id
  name    = "${var.testserver_hostname}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.management_common_base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.testserver[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_testserver" {
  count    = var.testserver_instancecount
  template = file("./resources/setup-server.sh")
  vars = {
    availability_zone = element(split(",", module.management_common_base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "testserver" {
  count = var.testserver_instancecount

  subnet_id                   = module.management_common_base_network.subnet_management[count.index].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.testserver_instancesize
  user_data                   = data.template_file.setup_testserver[count.index].rendered
  key_name                    = module.management_common_base_security.ssh_key_pair_internalnode_id

  credit_specification {
    cpu_credits = "standard"
  }
    
  root_block_device {
    volume_type = var.testserver_rootdisk_storage_type
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.management_common_base_network.common_securitygroup.id,
    [ 
      aws_security_group.wmtestserver.id 
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.testserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.testserver_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}

resource "aws_volume_attachment" "testserver" {
  count = var.testserver_instancecount
  
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.testserver[count.index].id
  instance_id = aws_instance.testserver[count.index].id
}

resource "aws_ebs_volume" "testserver" {
  count = var.testserver_instancecount

  availability_zone = module.management_common_base_network.subnet_management[count.index].availability_zone
  type              = var.testserver_datadisk_storage_type
  size              = var.testserver_datadisk_size_gb
  
  tags = merge(
    local.testserver_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.testserver_hostname}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}