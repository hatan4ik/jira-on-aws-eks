variable "vnet_id" {
  description = "ID of the virtual network to link the private DNS zone to."
  type        = string
}

variable "aks_subnet_id" {
  description = "ID of the AKS subnet to deploy the private endpoint into."
  type        = string
}