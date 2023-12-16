### General ###
variable "workload" {
  type    = string
  default = "airdata"
}

variable "location" {
  type    = string
  default = "eastus2"
}

### VM ###
variable "vm_size" {
  type    = string
  default = "Standard_B2pts_v2"
}
