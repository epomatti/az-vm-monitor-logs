### General ###
variable "subscription_id" {
  type = string
}

variable "workload" {
  type = string
}

variable "location" {
  type = string
}

### VM ###
variable "vm_size" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_public_key_path" {
  type = string
}

variable "vm_image_publisher" {
  type = string
}

variable "vm_image_offer" {
  type = string
}

variable "vm_image_sku" {
  type = string
}

variable "vm_image_version" {
  type = string
}
