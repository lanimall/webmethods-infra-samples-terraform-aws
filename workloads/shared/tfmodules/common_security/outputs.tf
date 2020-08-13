output "ssh_key_pair_internalnode_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_key_pair_internalnode_id
}

output "role_managementnode_role_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_management_node_role_id
}

output "role_managementnode_role_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_management_node_role_arn
}

output "instance_profile_managementnode_role_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_instance_profile_management_node_role_id
}

output "instance_profile_managementnode_role_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_instance_profile_management_node_role_arn
}

output "role_appnode_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_app_node_role_id
}

output "role_appnode_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_app_node_role_arn
}

output "instance_profile_appnode_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_instance_profile_app_node_role_id
}

output "instance_profile_appnode_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_instance_profile_app_node_role_arn
}

output "role_database_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_database_id
}

output "role_database_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_database_arn
}

output "role_backups_id" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_backups_id
}

output "role_backups_arn" {
  value = data.terraform_remote_state.base_security.outputs.aws_iam_role_backups_arn
}