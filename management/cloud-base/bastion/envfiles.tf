data "template_file" "setenv-bastion" {
  template = file("${path.cwd}/resources/setenv-bastion.template")
  vars = {
    bastion_linux_1_user                = var.common_compute_vm_linux.os_admin_user
    bastion_linux_1_hostname_public     = length(aws_instance.bastion_linux)>0 ? aws_instance.bastion_linux.0.public_ip : "null"
    
    bastion_linux_2_user                = var.common_compute_vm_linux.os_admin_user
    bastion_linux_2_hostname_public     = length(aws_instance.bastion_linux)>1 ? aws_instance.bastion_linux.1.public_ip : "null"

    bastion_windows_1_user              = var.common_compute_vm_windows.os_admin_user
    bastion_windows_1_hostname_public   = length(aws_instance.bastion_windows)>0 ? aws_instance.bastion_windows.0.public_ip : "null"

    bastion_windows_2_user              = var.common_compute_vm_windows.os_admin_user
    bastion_windows_2_hostname_public   = length(aws_instance.bastion_windows)>1 ? aws_instance.bastion_windows.1.public_ip : "null"
  }
}

resource "local_file" "setenv-bastion" {
  content  = data.template_file.setenv-bastion.rendered
  filename = join("/", [ pathexpand(var.env_output_dir), "setenv-bastion.sh" ] )
}