variable "region" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "simpletime-rg"
}

variable "aks_cluster_name" {
  type        = string
  description = "AKS cluster name"
  default     = "simpletime-aks"
}

variable "node_count" {
  type        = number
  description = "Number of AKS agent nodes"
  default     = 2
}

variable "docker_image" {
  type        = string
  description = "Docker image for the SimpleTimeService"
  default     = "hashmeetkaur53/simpletimeservice:latest"
}

variable "subscription_id" {
  type = string
  default = "value"
  description = "This is the subscription ID for Azure resources"
}