#!/bin/bash
set -e

export AWS_PROFILE=terraform-admin
export TF_DATA_DIR=/tmp/terraform-data
export TF_PLUGIN_CACHE_DIR=/tmp/terraform-plugin-cache

mkdir -p "$TF_DATA_DIR" "$TF_PLUGIN_CACHE_DIR"

cd "$HOME/aws-oracle-dba-automation/terraform"

echo "AWS identity:"
aws sts get-caller-identity

echo
echo "Terraform version:"
"$HOME/aws-oracle-dba-automation/tools/terraform" version

echo
echo "Terraform setup complete."
echo "Run terraform init if the temporary provider files are missing."
