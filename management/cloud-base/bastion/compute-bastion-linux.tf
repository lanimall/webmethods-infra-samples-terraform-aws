################################################
################ Outputs
################################################

output "bastion_linux-public_ip" {
  value = aws_eip.bastion_linux.*.public_ip
}

output "bastion_linux-public_dns" {
  value = aws_eip.bastion_linux.*.public_dns
}

output "bastion_linux-private_dns" {
  value = aws_instance.bastion_linux.*.private_dns
}

output "bastion_linux-private_ip" {
  value = aws_instance.bastion_linux.*.private_ip
}

################################################
################ Vars
################################################

variable "instancesize_bastion_linux" {
  description = "instance type for bastion"
}

variable "instancecount_bastion_linux" {
  description = "number of bastion nodes"
}

variable "hostname_bastion_linux" {
  description = "hostname"
}

locals {
  bastion_linux_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  bastion_linux_ips = aws_instance.bastion_linux.*.private_ip
}

################################################
################ DNS
################################################

resource "aws_route53_record" "bastion_linux" {
  count = var.instancecount_bastion_linux

  zone_id = module.base_network.dns_internal.zone_id
  name    = "${var.hostname_bastion_linux}${count.index + 1}.${module.global_common_base.name_prefix_long}.${module.base_network.dns_internal_apex}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.bastion_linux[count.index].private_ip
  ]
}

################################################
################ VM specifics
################################################

// create eip for bastion_linux
resource "aws_eip" "bastion_linux" {
  count = var.instancecount_bastion_linux

  vpc = true

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_linux${count.index + 1}-${module.base_network.subnet_dmz[count.index].availability_zone}"
      "az"   = module.base_network.subnet_dmz[count.index].availability_zone
    },
  )
}

resource "aws_eip_association" "bastion_linux" {
  count = var.instancecount_bastion_linux
  
  instance_id   = aws_instance.bastion_linux[count.index].id
  allocation_id = aws_eip.bastion_linux[count.index].id
}

//Create the bastion userdata script.
data "template_file" "setup_bastion_linux" {
  count    = var.instancecount_bastion_linux
  template = file("./resources/setup-bastion-linux.sh")
  vars = {
    availability_zone = element(split(",", module.base_network.network_az_mapping[local.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion_linux" {
  count = var.instancecount_bastion_linux

  subnet_id                   = module.base_network.subnet_dmz[count.index].id
  ami                         = module.global_common_base_compute.common_instance_linux_ami
  instance_type               = var.instancesize_bastion_linux
  user_data                   = data.template_file.setup_bastion_linux[count.index].rendered
  key_name                    = module.base_security.ssh_key_pair_bastion_id
  associate_public_ip_address = "true"

  credit_specification {
    cpu_credits = "standard"
  }
  
  root_block_device {
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.bastion_linux.id]

  //  Use our common tags and add a specific name.
  tags = merge(
    local.bastion_linux_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-bastion_linux${count.index + 1}-${module.base_network.subnet_dmz[count.index].availability_zone}"
      "az"   = module.base_network.subnet_dmz[count.index].availability_zone
    },
  )
}