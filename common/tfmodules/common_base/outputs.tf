output "name_friendly_id" {
  value = local.name_friendly_id
}

output "name_prefix_long" {
  value = local.name_prefix_long
}

output "name_prefix_long_nouuid" {
  value = local.name_prefix_long_nouuid
}

output "name_prefix_short" {
  value = local.name_prefix_short
}

output "project_name_clean" {
  value = local.project_name_clean
}

output "workload_name_clean" {
  value = local.workload_name_clean
}

output "workload_code_clean" {
  value = local.workload_code_clean
}

output "provisioning_stack_clean" {
  value = local.provisioning_stack_clean
}

output "common_tags" {
  value = local.common_tags
}

output "name_delimiter" {
  value = local.name_delimiter
}

output "hostname_delimiter" {
  value = local.hostname_delimiter
}

output "inventory_filename_delimiter" {
  value = local.inventory_filename_delimiter
}

output "uuid" {
  value = module.common_uuid.uuid
}