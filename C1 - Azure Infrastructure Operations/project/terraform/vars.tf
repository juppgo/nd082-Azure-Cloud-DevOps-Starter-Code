variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "udacity-project-c1"
  type        = string
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "East US"
  type        = string
}

variable "username" {
  description = "Username to login to VM"
  default     = "adminuser"
  type        = string
}

variable "password" {
  description = "passwrod to login to vm"
  default     = "54f3p455W0rd!"
  type        = string
}

variable "vm_number" {
  description = "number of VMs to be created"
  default     = 4
  type        = number
}

variable "image_id" {
  default = "/subscriptions/0c7436df-9359-4a04-b572-96ab6d89334c/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/ubuntuImage"
  type    = string
}
