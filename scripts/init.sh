#!/bin/bash
set -e

echo "Provisioning ECR repositories and DynamoDB tables"
echo ""
cd iac/base
terraform init
terraform apply -auto-approve

# get the primary and replicated repo urls
repo=$(terraform output -raw ecr_repo_url)
repo_replicated=$(terraform output -raw ecr_repo_url_replicated)

echo ""
echo "Pushing app to ECR"
echo ""
# login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ${repo}

# generate a random image tag
version=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
image=${repo}:${version}

# build and push our container image to ECR
docker buildx build --push -t ${image} --platform linux/amd64 ../../

echo ""
echo "Provisioning resources in Region A"
echo ""
cd ../region-a
terraform init
terraform apply -var="image=${image}" -auto-approve

echo ""
echo "Provisioning resources in Region B"
echo ""
cd ../region-b
image=${repo_replicated}:${version}
terraform init
terraform apply -var="image=${image}" -auto-approve

echo ""
echo "done"