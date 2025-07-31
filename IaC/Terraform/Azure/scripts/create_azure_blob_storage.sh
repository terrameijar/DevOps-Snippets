# Variables
RESOURCE_GROUP=migration-lab
STORAGE_ACCOUNT=migstorage$RANDOM
CONTAINER_NAME=vhd-container
SAS_TOKEN=""

# Create RG and Storage Account
az group create --name $RESOURCE_GROUP --location westus2
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location westus2 --sku Standard_LRS

# Get storage key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)

# Create Blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --account-key $ACCOUNT_KEY

# Create SAS Token
SAS_TOKEN=$(az storage container generate-sas \
  --account-name $STORAGE_ACCOUNT \
  --name $CONTAINER_NAME \
  --permissions rl \
  --expiry 2025-07-22T00:00Z \
  --output tsv)

# Upload VHD
# az storage blob upload --account-name $STORAGE_ACCOUNT --account-key $ACCOUNT_KEY \
#   --container-name $CONTAINER_NAME \
#   --file ./your-exported-image.vhd \
#   --name your-exported-image.vhd

# Export AWS Credentials
export AWS_ACCESS_KEY_ID=abcdef1234
export AWS_SECRET_ACCESS_KEY=abcdef1234sjfalsdfjalnf

# Copy from AWS S3
azcopy copy \
https://vndlovu-cloud-migration.s3.eu-west-1.amazonaws.com/vmimportexport_write_verification.txt \
"https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME?$SAS_TOKEN" --recursive

# Create Managed Disk from Uploaded VHD