# Azure Terraform Configuration

This directory contains the main Terraform configuration files for deploying and managing Azure infrastructure resources.

## Table of contents

- [main.tf](./main.tf) - Main Terraform configuration defining Azure resources
- [variables.tf](./variables.tf) - Variable definitions and descriptions
- [terraform.tfvars](./terraform.tfvars) - Variable values and environment-specific settings

## Overview

This Terraform configuration provides:

- **Azure Resource Management**: Define and deploy Azure virtual machines, storage, and networking
- **Infrastructure as Code**: Declarative configuration for repeatable deployments
- **Variable-driven Configuration**: Flexible parameterization for different environments
- **State Management**: Terraform state tracking for infrastructure changes

## Usage

### Prerequisites

- Azure CLI installed and configured
- Terraform installed (version 0.12+)
- Appropriate Azure subscription and permissions

### Deployment Steps

1. **Initialize Terraform**:

   ```bash
   terraform init
   ```

2. **Review the plan**:

   ```bash
   terraform plan
   ```

3. **Apply the configuration**:

   ```bash
   terraform apply
   ```

4. **Destroy resources** (when needed):
   ```bash
   terraform destroy
   ```

### Configuration

Edit `terraform.tfvars` to customize variables for your environment:

```hcl
# Example configuration
location = "East US"
resource_group_name = "my-rg"
vm_size = "Standard_B2s"
```

Refer to `variables.tf` for all available configuration options and their descriptions.
