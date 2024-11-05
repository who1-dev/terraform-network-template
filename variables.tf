variable "default_tags" {
  default = {
    "Name"  = "jcaranay-vpc"
    "Owner" = "jcaranay"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

variable "namespace" {
  type    = string
  default = "JASN"
}

variable "app_role" {
  type    = string
  default = "Networking"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type = string
}

variable "remote_data_sources" {
  type = map(object({
    bucket = string
    key    = string
    region = string
  }))
  default = {
    network = {
      bucket = "acs730-assignment-jcaranay"
      key    = "dev/networking/terraform.tfstate"
      region = "us-east-1"
    }
  }
}


variable "vpcs" {
  type = map(object({
    name       = string
    cidr_block = string
  }))
}

variable "igws" {
  type = map(object({
    name    = string
    vpc_key = string
    rt_key  = string
  }))
}

variable "public_route_table" {
  type = map(object({
    name    = string
    vpc_key = string
  }))
}

variable "public_subnets" {
  type = map(object({
    name              = string
    vpc_key           = string
    rt_key            = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_route_table" {
  type = map(object({
    name    = string
    vpc_key = string
  }))
}

variable "private_subnets" {
  type = map(object({
    name              = string
    vpc_key           = string
    rt_key            = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "eips" {
  type = map(object({
    name = string
  }))
}


variable "natgws" {
  type = map(object({
    name        = string
    eip_key     = string
    pub_sub_key = string,
    rt_key      = string
  }))
}

variable "vpc_peering_connections" {
  type = map(object({
    vpc_key     = string
    is_local    = bool
    remote_key  = string
    peer_vpc_id = string
    name        = string
  }))
  default = {
  }
}

variable "vpc_peering_connection_routes" {
  type = map(object({
    is_local                       = bool
    remote_key                     = string
    rt_key                         = string
    destination_cidr_block_vpc_key = string
    vpc_peering_connection_id      = string
  }))
  default = {
  }
}

