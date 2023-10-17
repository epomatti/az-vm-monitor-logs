variable "workload" {
  type    = string
  default = "examplecorp"
}

variable "location" {
  type    = string
  default = "brazilsouth"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "monitor_agent_enabled" {
  type    = bool
  default = true
}
