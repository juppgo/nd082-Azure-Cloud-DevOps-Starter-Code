variable "prefix" {
  description = "The prefix used for all resources in this example"
  default = "udacity"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "username" {
    description = "Username to login to VM"
    default = "adminuser"
}

variable "password" {
    description = "passwrod to login to vm"
    default = "54f3p455w0rd"
}