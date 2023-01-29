variable "resource_group_name" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
  default     = null
}

variable "tags" {
  description = "The tags to associate with resource"
  type        = map(any)

}

variable "address_prefixes" {
  description = "The address prefix to use for the subnet."
  #type = string
  type        = list(string)
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  #type = string
  type        = list(string)
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
}


#nsg variables
variable "nsg_name" {
    description = "The name of the network security group "
  type = list(string)
  
}

variable "nsg_subnet_association" {
    description = "subnet association"
    type = bool
    default = false
}

variable "route_table_name" {
  description = "The subnet id for network security group association"
  type = list(string)
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type = string
}

variable "subnet_ids" {
  description = "The id of the subnet ids"
  type = list(string)
  
}