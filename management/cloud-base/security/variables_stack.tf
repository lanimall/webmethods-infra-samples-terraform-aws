variable "ssh_bastion_publickey_path" {
  description = "My secure bastion ssh public key"
}

variable "ssh_internal_publickey_path" {
  description = "My secure internal ssh public key"
}

variable "ssh_bastion_key_name" {
  description = "secure bastion ssh key name"
}

variable "ssh_internalnode_key_name" {
  description = "secure ssh key name for internal nodes"
}