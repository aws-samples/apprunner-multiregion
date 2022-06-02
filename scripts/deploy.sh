#!/bin/bash
set -e

echo ""
echo "Pushing app to ECR"
echo ""
cd iac/base
repo=$(terraform output -raw ecr_repo_url)
repo_replicated=$(terraform output -raw ecr_repo_url_replicated)

# login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ${repo}

# generate a random image tag
version=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
image=${repo}:${version}

# build and push our container image to ECR
docker buildx build --push -t ${image} --platform linux/amd64 ../../.

echo ""
echo "Updating AppRunner Service in region A"
echo ""
cd ../region-a
region=$(terraform output -raw region)
export AWS_REGION=$region
service_arn=$(terraform output -raw service_arn)
aws apprunner update-service \
	--cli-input-json '{ "ServiceArn": "'${service_arn}'", "SourceConfiguration": { "ImageRepository": { "ImageRepositoryType": "ECR", "ImageIdentifier": "'${image}'" } } }'

echo ""
echo "pausing to allow for ECR cross region replication"
sleep 15

echo ""
echo "Updating AppRunner Service in region B"
echo ""
cd ../region-b
region=$(terraform output -raw region)
export AWS_REGION=$region
image=${repo_replicated}:${version}
service_arn=$(terraform output -raw service_arn)
aws apprunner update-service \
	--cli-input-json '{ "ServiceArn": "'${service_arn}'", "SourceConfiguration": { "ImageRepository": { "ImageRepositoryType": "ECR", "ImageIdentifier": "'${image}'" } } }'

echo "Deployment initiated"