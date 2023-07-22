### General ###
variable "workload" {
  type    = string
  default = "airdata"
}

variable "location" {
  type    = string
  default = "brazilsouth"
}

### VM ###
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  type    = string
  default = "22_04-lts-gen2"
}

variable "vm_image_version" {
  type    = string
  default = "latest"
}
