# Import AWS EC2 VHD to Azure VM

This guide covers importing a `.vhd` image exported from AWS into Azure and booting it as a virtual machine.

---

## ✅ Prerequisites

- VHD image from AWS stored locally
- The VHD file must be in fixed format and not dynamic
- If VHD image is dynamically sized, change it to fixed: `Convert-VHD -Path "C:\path\to\dynamic.vhd" - DestinationPath "C:\path\to\fixed.vhd" -VHDType Fixed`
- Azure CLI installed
- Subscription access with permissions to create disks, NICs, and VMs

---

## 🛠️ Steps

### 1. Create Storage Account and Blob Container

```bash
RESOURCE_GROUP=migration-lab
STORAGE_ACCOUNT=migstorage$RANDOM
CONTAINER_NAME=vhd-container

az group create --name $RESOURCE_GROUP --location eastus
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location eastus --sku Standard_LRS
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --account-key $ACCOUNT_KEY
```

### 2. Upload the VHD File

```bash
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY \
  --container-name $CONTAINER_NAME \
  --file ./your-exported-image.vhd \
  --name your-exported-image.vhd
```

Alternatively, copy it directly from AWS to Azure:

_Create SAS Token_

```bash
SAS_TOKEN=$(az storage container generate-sas \
  --account-name $STORAGE_ACCOUNT \
  --name $CONTAINER_NAME \
  --permissions rl \
  --expiry 2025-07-22T00:00Z \
  --output tsv)
```

**Export AWS Credentials**

```shell
export AWS_ACCESS_KEY_ID=abcdef1234
export AWS_SECRET_ACCESS_KEY=abcdef1234sjfalsdfjalnf
```

**Copy from S3**

```bash
# Copy from S3
azcopy copy \
https://vndlovu-cloud-migration.s3.eu-west-1.amazonaws.com/vmimportexport_write_verification.txt \
"https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME?$SAS_TOKEN" --recursive
```

### 3. Create a Managed Disk from the VHD

```bash
az disk create \
  --resource-group $RESOURCE_GROUP \
  --name aws-exported-disk \
  --source https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME/your-exported-image.vhd \
  --os-type Linux

```

### 4. Provision Networking (via Terraform)

- VNet + Subnet
- NSG with SSH + HTTP
- Public IP
- NIC

Use the Terraform in `azure/terraform` to provision the networking infrastructure automatically.

### 5. Create VM from Disk

```bash
az vm create \
    --name migrated-vm \
    --resource-group $RESOURCE_GROUP \
    --attach-os-disk aws-exported-disk \
    --os-type Linux \
    --nics vm-nic \
    --size Standard_B1s \
    --generate-ssh-keys
```

## Lessons

- VM image compatibility (AWS to Azure)
- Security and firewall differences
- Blob storage and managed disk workflows
- Networking translation (SG vs NSG)

- Azure doesn't support dynamically-sized VHDs that most tools default to
- Convert the dynamic VHD to a fixed VHD before uploading
  - install `qemu-utils` or use Powershell with the Hyper-V role enabled.
- Images might have to be resized: `qemu-img info export-fixed.vhd,qemu-img resize export-fixed.vhd 8192M`
- Ensure you upload with `--type page`, not block(default) -- Azure doesn't support block blobs for disk creation.
