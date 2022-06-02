#!/bin/bash
set -e

cd iac/base
repo=$(terraform output -raw ecr_repo_url)
repo_replicated=$(terraform output -raw ecr_repo_url_replicated)

echo ""
echo "Destroying AppRunner Service in Region B"
echo ""
cd ../region-b
image=$(terraform output -raw image)
terraform apply -destroy -auto-approve -var="image=${image}"

echo ""
echo "Destroying AppRunner Service in Region A"
echo ""
cd ../region-a
image=$(terraform output -raw image)
terraform apply -destroy -auto-approve -var="image=${image}"

echo "Destroying ECR repositories and DynamoDB tables"
echo ""
cd ../base
terraform apply -destroy -auto-approve

echo ""
echo "done"