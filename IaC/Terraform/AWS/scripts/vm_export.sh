# Get Instance IDs
aws ec2 describe-instances \
    --filters Name=tag-key,Values=Name \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output table

# Create AMI Image from Instance
# The command will return an image ID, but it takes a few minutes for the image to be built.

aws ec2 create-image \
    --instance-id $instance_id \
    --name "MigrationAMI" \
    --no-reboot



# Capture the `ImageID`
aws ec2 wait image-available --image-ids ami-abc123456

# Create an S3 Bucket
aws s3 mb s3://vndlovu-cloud-migration-test2

# Create IAM Role for VM Import/Export

# create trust policy
# https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/
# https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role

# VM Export requires a role to perform certain operations on your behalf. 

aws iam create-role \
    --role-name vmimport \
    --assume-role-policy-document file://trust-policy.json


# Attach a policy that allows access to the S3 bucket and EBS


# Attach IAM policies that give the AWS VM import service permission to perform VM migrations
aws iam put-role-policy \
 --role-name vmimport \
 --policy-name vmimport \
 --policy-document file://vmimport-permissions.json

# Start an export task to export the AMI to S3
aws ec2 export-image \
    --image-id ami-abc123456 \
    --disk-image-format VHD \
    --s3-export-location S3Bucket=my-export-bucket,S3Prefix=exports/


# Check on export status
aws ec2 describe-export-image-tasks