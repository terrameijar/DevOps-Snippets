# Export EC2 Instance to VHD (for Azure Migration)

This guide documents the process of exporting an EC2 instance to a VHD format for importing into Azure.

---

## ✅ Prerequisites

- EC2 instance created with Terraform (see `aws/terraform/`)
- Instance contains your app/data
- AWS CLI configured with permissions:
  - `ec2:CreateImage`, `ec2:ExportImage`, `s3:PutObject`, etc.

---

## 🛠️ Steps

### 1. Stop EC2 and Create an AMI

```bash
# Get Instance IDs
aws ec2 describe-instances \
    --filters Name=tag-key,Values=Name \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output table

aws ec2 stop-instances --instance-ids i-xxxxxxxxxxxxxxxxx

# Create AMI Image from Instance
# The command will return an image ID, but it takes a few minutes for the image to be built.

aws ec2 create-image \
    --instance-id $instance_id \
    --name "MigrationAMI" \
    --no-reboot
```

### 2. Create an S3 Bucket for Export

The bucket must be in the same region as your EC2 instance.

```bash
aws s3 mb s3://my-ec2-vhd-bucket
```

### 3. Set up IAM Role for Export

Create a role named `vmimport` with the trust policy below(named `trust-policy.json`)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "vmie.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "vmimport"
                }
            }
        }
    ]
}
```

**Steps:** 
- Create IAM Role for VM Import/Export
- create trust policy
<!--  https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/ -->
 <!-- https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role -->
<!--  VM Export requires a role to perform certain operations on your behalf.  -->

```bash
aws iam create-role \
    --role-name vmimport \
    --assume-role-policy-document file://trust-policy.json
```

**Create a permissions policy to allow the AWS VM Export service to perform exports and access the S3 bucket and EBS**

Create the policy `vmimport-permissions.json`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::vndlovu-cloud-migration-test2"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::vndlovu-cloud-migration-test2/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:ModifySnapshotAttribute",
                "ec2:CopySnapshot",
                "ec2:RegisterImage",
                "ec2:Describe*"
            ],
            "Resource": "*"
        }
    ]
}
```

Attach it

```bash
aws iam put-role-policy \
 --role-name vmimport \
 --policy-name vmimport \
 --policy-document file://vmimport-permissions.json
 ```


### 4. Export the Image to S3
Start an export task to export the AMI to S3

```bash
aws ec2 export-image \
    --image-id ami-abc123456 \
    --disk-image-format VHD \
    --s3-export-location S3Bucket=my-export-bucket,S3Prefix=exports/
```


Check on export status

```bash
aws ec2 describe-export-image-tasks
```
Download the final `.vhd` file from S3.
