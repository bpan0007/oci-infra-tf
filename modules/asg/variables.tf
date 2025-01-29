
variable "compartment_id" {
  description = "The OCID of the compartment in which to create the VCN."
  type        = string
}

variable "region" {
  description = "The region to provision resources in"
  type        = string
  default     = "us-ashburn-1"
}

variable "ssh_public_key" {
  description = "The public key to use for SSH access"
  type        = string
}


variable "lb-port" {
  description = "The port for the load balancer"
  type        = number
  default     = 8080

}

variable "instance_shape" {
  default = "VM.Standard.E2.1" # VM.Standard.E2.1 Or VM.Standard.E2.1.Micro Or VM.Standard.A1.Flex
}

# variable "subnet_ids" {
#   type = list(object({
#     id      = string
#     private = bool
#   }))
#   description = "Subnet ID and private flag for the load balancer"
# }

variable "lb_id" {
  description = "ID of the load balancer"
  type        = string
}

variable "backend_set_name" {
  description = "Name of the load balancer backend set"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}