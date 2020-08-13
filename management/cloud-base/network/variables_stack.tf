
variable "dns_external_apex" {
  description = "top domain of the external DNS"
}

variable "dns_internal_apex" {
  description = "top domain for the internal DNS"
}

### Availability zones to use per region for all the subnets
variable "availability_zones_mapping" {
  default = {
    "us-east-1" = "us-east-1a,us-east-1b"
    "us-east-2" = "us-east-2a,us-east-2b"
    "us-west-1" = "us-west-1a,us-west-1b"
    "us-west-2" = "us-west-2a,us-west-2b"
  }
}