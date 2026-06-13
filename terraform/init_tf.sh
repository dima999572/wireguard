#!/usr/bin/env bash

set -e

# --- CONFIGURATION VARIABLES ---
UNIQUE_SUFFIX=$(date +%s)
BUCKET_NAME="dima999572-ec2-tfstate" 
REGION="eu-central-1"
# ------------------------------

echo "Creating S3 bucket: $BUCKET_NAME in region $REGION..."

# Create S3 bucket with the location constraint for eu-central-1
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

echo "--------------------------------------------------------"
echo "S3 Bucket created successfully."
echo "Bucket Name: $BUCKET_NAME"
echo "Region:      $REGION"
echo "--------------------------------------------------------"