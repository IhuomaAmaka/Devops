variable "region" {
  type        = string
  description = "Region to launch vpc"
}
variable "cidr" {
  type        = string
  description = "The CIDR of the VPC."
}

variable "public_subnet" {
  type        = string
  description = "The public subnet to create."
}
variable "private_subnet" {
  type        = string
  description = "The public subnet to create."
}

variable "public1_subnet" {
  type        = string
  description = "The public subnet to create."
}
variable "private1_subnet" {
  type        = string
  description = "The public subnet to create."
}

variable "instance_type" {
  type        = string
  description = "The type of instance to launch"
}
/*variable "key_name" {
  type        = string
  description = "Key used to connect to instance generated"
}*/
variable "cluster_name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "eks_node" {
  type        = string
  description = "name of eks nodes"
}
variable "node_ami_type" {
  type        = string
  description = "type of AMI associated with eks nodes"
}
