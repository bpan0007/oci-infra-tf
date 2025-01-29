# OCI Infrastructure Project

This project implements a basic infrastructure setup in Oracle Cloud Infrastructure (OCI) using Terraform. It creates a Virtual Cloud Network (VCN) with public and private subnets, a load balancer, and an auto-scaling group configuration in public subnet running nginx server.

## Architecture

The infrastructure consists of:
- VCN with custom CIDR block
- Public and private subnets
- Load Balancer
- Auto Scaling Group
- Internet Gateway for public access

## Prerequisites

- Terraform >= 1.7
- OCI CLI configured
- Valid OCI credentials
- SSH key pair for instance access

## Configuration

Create a `terraform.tfvars.json` file with your network configuration:
```json
{
  "cidr_block": "10.0.0.0/16",
  "subnets": [
    {
      "name": "public-subnet",
      "cidr_block": "10.0.0.0/24",
      "private": false
    },
    {
      "name": "private-subnet-1",
      "cidr_block": "10.0.1.0/24",
      "private": true
    },
    {
      "name": "private-subnet-2",
      "cidr_block": "10.0.2.0/24",
      "private": true
    }
  ]
}
```

## Project Structure

```
.
├── main.tf              # Main Terraform configuration
├── output.tf           # Output definitions
├── modules/
│   ├── vcn/           # VCN module
│   ├── lb/            # Load Balancer module
│   └── asg/           # Auto Scaling Group module
└── tests/             # Terratest test files
```

## Usage

1. Setup OCI credentials

#!/bin/zsh
# Set these in your ~/.zshrc or ~/.bash_profile
export TF_VAR_tenancy_ocid=""
export TF_VAR_user_ocid=""
export TF_VAR_fingerprint=""
export TF_VAR_private_key_path=""
export TF_VAR_compartment_id=""
export TF_VAR_ssh_public_key=""


1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Testing

The project includes Terratest configurations for infrastructure testing. To run tests:

```bash
cd tests
go test -v
```

## Outputs

- `subnet_ids_list`: List of all subnet IDs
- `lb_id`: Load Balancer ID
- `backend_set_name`: Name of the backend set
- `single_subnet_id`: ID of the public subnet

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Security Notes

- Ensure proper security group rules are configured
- Keep your private keys secure
- Follow OCI security best practices

## Requirements

- OCI Provider >= 6.18.0
- Terraform >= 1.7
- Go >= 1.23.4 (for testing)
