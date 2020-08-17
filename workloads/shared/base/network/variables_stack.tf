
variable "dns_external_apex" {
  description = "top domain of the external DNS"
}

variable "dns_internal_apex" {
  description = "top domain for the internal DNS"
}

variable "availability_zones_mapping" {
  description = "Availability zones to use per region for all the subnets"
}

variable "ssl_cert_mainlb_key_path" {
  description = "top domain for the internal DNS"
}

variable "ssl_cert_mainlb_pub_path" {
  description = "top domain for the internal DNS"
}

variable "ssl_cert_mainlb_ca_path" {
  description = "top domain for the internal DNS"
}