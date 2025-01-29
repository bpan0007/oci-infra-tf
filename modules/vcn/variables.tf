
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

variable "subnets" {
  description = "JSON configuration for subnets"
  type = list(object({
    name            = string
    cidr_block      = string
    dns_label       = optional(string, null)
    private         = optional(bool, true)
    dhcp_options_id = optional(string)
  }))
}

variable "cidr_block" {
  description = "The CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "lb-port" {
  description = "The port for the load balancer"
  type        = number
  default     = 8080

}

variable "instance_shape" {
  default = "VM.Standard.E2.1" # VM.Standard.E2.1 Or VM.Standard.E2.1.Micro Or VM.Standard.A1.Flex
}

variable "igw" {
    description = "Create an internet gateway"
    type        = bool
    default     = true
}

# variable public_subnet_id {
#     description = "Public subnet ID"
#     type        = string
# }
    
