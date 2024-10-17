#!/bin/bash

# Uploads files to an AWS S3 bucket

bucket_name=""
GeneratePresignedURL=false

Help()
{
    echo "This script uploads files to an S3 bucket."
    echo
    echo "Usage: ./uploader.sh -s source_path -d dest_path [-p]"
    echo
    echo "Options:"
    echo "-h                        Print this help"
    echo "-s source                 Specify the source file path to upload."
    echo "-b bucket                 Specify the S3 bucket name."
    echo "-d dest                   Specify the destination directory in the S3 bucket."
    echo "-p presigned url          Generate a presigned URL after upload (optional)."
}

CreateFolder() {
    local directory="$1"
    if [[ -n "$bucket_name" ]]; then
        aws s3api put-object --bucket "$bucket_name" --key "$directory/" > /dev/null 2>&1
    else
        return 1
    fi

    if [[ $? -eq 0 ]]; then
        echo -e ">>> \033[32mSUCCESS]\033[0m Folder '$directory' was created successfully."
    else
        echo -e ">>> \033[31m[ERROR]\033[0m Folder creation failed."
    fi
}


UploadFile(){
    # Upload file to destination directory in the cloud
    echo

    local file_name="$1"
    local destination_directory="$2"

    if [[ -f "$file_name" ]]; then
        if [[ -n "$destination_directory" ]]; then
            s3_path="s3://$bucket_name/$destination_directory/$(basename $file_name)"
        else
            s3_path="s3://$bucket_name/$(basename $file_name)"
        fi

        echo "Uploading $1 to $s3_path...."
        echo

        error_message=$(aws s3 cp "$file_name" "$s3_path" --quiet 2>&1)

        if [[ error_message -eq 0 ]]; then
            echo -e ">>> \033[32m[SUCCESS]\033[0m $file_name was uploaded successfully to $s3_path"
            if [[ "$GeneratePresignedURL" == true ]]; then
                echo "Generating presigned URL..."
                region=$(aws s3api get-bucket-location --bucket "$bucket_name" --query 'LocationConstraint' --output text)
                FilePresignedURL=$(aws s3 presign "$s3_path" --region "$region")
                echo
                echo "$FilePresignedURL"
                echo
            fi
        else
            echo -e ">>> \033[31m[ERROR]\033[0m File Upload failed!\n\t\t$error_message"
        fi
    
    fi
}


while getopts 's:d:b:ph' option; do
    case "${option}" in
        h)
            Help
            exit 0;;
        s)  SourcePath=$OPTARG
            ;;
        b)  bucket_name=$OPTARG;;
        d)  DestPath=$OPTARG
            CreateFolder "$DestPath"
            ;;
        p) # Toggle presigned URL generation
            GeneratePresignedURL=true;;
        \?) # Invalid option
            echo "Error: Invalid option"
            Help
            exit 1;;
    esac
done


if [[ -z "$SourcePath" || -z "$bucket_name" ]]; then
    echo "Error: Source path and bucket name required."
    Help
    exit 1
fi

UploadFile $SourcePath $DestPath