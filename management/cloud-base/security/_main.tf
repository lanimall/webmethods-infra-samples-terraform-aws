module "global_common_base" {
  source = "../../../common/tfmodules/common_base"

  project_name = var.project_name
  project_code = var.project_code
  environment_level = var.environment_level
  workload_name = var.workload_name
  workload_code = var.workload_code
  workload_description = var.workload_description
  provisioning_type = var.provisioning_type
  provisioning_git = var.provisioning_git
  provisioning_stack = var.provisioning_stack
  owners = var.owners
  organization = var.organization
  team = var.team
}