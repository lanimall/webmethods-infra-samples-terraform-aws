############# ssh keys ############

output "aws_key_pair_internalnode_id" {
  value = aws_key_pair.internalnode.id
}

locals {
  awskeypair_internal_node    = "${module.global_common_base.name_prefix_long}-${var.ssh_internalnode_key_name}"
  awskeypair_internal_keypath = "${var.ssh_internal_publickey_path}"
}

## key creation for internal nodes
resource "aws_key_pair" "internalnode" {
  key_name   = local.awskeypair_internal_node
  public_key = file(local.awskeypair_internal_keypath)

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${local.awskeypair_internal_node}"
    },
  )
}