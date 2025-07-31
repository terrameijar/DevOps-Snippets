# Azure Terraform Scripts

This directory contains utility scripts and cloud-config files for Azure infrastructure automation and management using Terraform.

## Table of contents

- [cloud-config.yaml](./cloud-config.yaml) - Sample Cloud-init configuration for Azure virtual machines
- [create_azure_blob_storage.sh](./create_azure_blob_storage.sh) - Script for creating Azure Blob Storage containers

## Overview

The scripts in this directory provide:

- **VM Configuration**: Cloud-init scripts for initial Azure virtual machine setup
- **Storage Management**: Tools for creating and managing Azure Blob Storage resources
- **Automation Utilities**: Helper scripts for common Azure operations and resource provisioning

## Usage

These scripts are typically referenced by Terraform configurations in the parent directory or used independently for specific Azure operations. Each script contains inline documentation for specific usage instructions.

### Examples

```bash
# Create Azure Blob Storage
./create_azure_blob_storage.sh

# Use cloud-config.yaml in Terraform
data "template_file" "cloud_config" {
  template = file("${path.module}/scripts/cloud-config.yaml")
}
```

Refer to individual script files for detailed parameters and configuration options.
