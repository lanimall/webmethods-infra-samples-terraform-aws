################################################
################ Outputs
################################################

output "management_linux-private_dns" {
  value = aws_instance.management_linux.*.private_dns
}

output "management_linux-private_ip" {
  value = aws_instance.management_linux.*.private_ip
}

################################################
################ Vars
################################################

variable "instancesize_management_linux" {
  description = "instance type for bastion"
}

variable "instancecount_management_linux" {
  description = "number of bastion nodes"
}

variable "hostname_management_linux" {
  description = "hostname"
}

locals {
  management_linux_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  management_linux_ips = aws_instance.management_linux.*.private_ip
}

################################################
################ DNS
################################################

resource "aws_route53_record" "management_linux" {
  count = var.instancecount_management_linux

  zone_id = module.management_common_base_network.dns_internal.zone_id
  name    = "${var.hostname_management_linux}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.management_common_base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.management_linux[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

//Create the bastion userdata script.
data "template_file" "setup_management_linux" {
  count    = var.instancecount_management_linux
  template = file("./resources/setup-management.sh")
  vars = {
    availability_zone = element(split(",", module.management_common_base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "management_linux" {
  count = var.instancecount_management_linux

  subnet_id                   = module.management_common_base_network.subnet_management[count.index].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.instancesize_management_linux
  user_data                   = data.template_file.setup_management_linux[count.index].rendered
  key_name                    = module.management_common_base_security.ssh_key_pair_internalnode_id

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    delete_on_termination = true
  }

  vpc_security_group_ids = flatten([
    module.management_common_base_network.common_securitygroup.id,
    [ 
      aws_security_group.management_linux.id 
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.management_linux_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-${var.hostname_management_linux}${count.index + 1}-${module.management_common_base_network.subnet_management[count.index].availability_zone}"
      "az"   = module.management_common_base_network.subnet_management[count.index].availability_zone
    },
  )
}