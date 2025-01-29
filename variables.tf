
variable "compartment_id" {
  description = "The OCID of the compartment in which to create the VCN."
  type        = string
}

variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the key"
  type        = string
}

variable "private_key_path" {
  description = "The path to your private key file"
  type        = string
}

variable "region" {
  description = "The region to provision resources in"
  type        = string
  default     = "us-phoenix-1"
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

