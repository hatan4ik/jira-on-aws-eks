variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
}

variable "prefix" {
  description = "Prefix for naming resources."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to deploy the Application Gateway into."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}
