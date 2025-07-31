# AWS Terraform Scripts

This directory contains utility scripts and cloud-config files for AWS infrastructure automation and management using Terraform.

## Table of contents

- [cloud-config.yaml](./cloud-config.yaml) - Sample Cloud-init configuration for EC2 instances
- [trust_policy.json](./trust_policy.json) - IAM trust policy definitions
- [user-data.sh](./user-data.sh) - Sample EC2 user data script for instance initialization
- [vm_export.sh](./vm_export.sh) - Script for exporting VM images
- [vmimport-permissions.json](./vmimport-permissions.json) - IAM permissions for VM import operations

## Overview

The scripts in this directory provide:

- **Instance Configuration**: Cloud-init and user data scripts for automated EC2 setup
- **IAM Policies**: Trust policies and permission definitions for secure resource access
- **VM Migration**: Tools and scripts for importing/exporting virtual machine images
- **Automation Utilities**: Helper scripts for common AWS operations

## Usage

These scripts are typically referenced by Terraform configurations in the parent directory or used independently for specific AWS operations. Each script contains inline documentation for specific usage instructions.

### Examples

```bash
# Execute VM export script
./vm_export.sh

# Use cloud-config.yaml in Terraform
data "template_file" "cloud_config" {
  template = file("${path.module}/scripts/cloud-config.yaml")
}
```

Refer to individual script files for detailed parameters and configuration options.
