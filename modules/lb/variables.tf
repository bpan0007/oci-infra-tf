
variable "compartment_id" {
  description = "The OCID of the compartment in which to create the VCN."
  type        = string
}


variable "region" {
  description = "The region to provision resources in"
  type        = string
 
}

variable "lb-port" {
  description = "The port for the load balancer"
  type        = number
  default     = 8080

}
variable "vcn_id" {
  description = "VCN ID from VCN module"
  type        = string
}

variable "subnet_ids" {
  type = list(object({
    id      = string
    private = bool
  }))
  description = "Subnet ID and private flag for the load balancer"
}