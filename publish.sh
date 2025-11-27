#!/bin/sh
set -eu

LAMBDA_DIR="./lambda"

# Extract version from pyproject.toml
IMAGE_TAG=$(grep '^version' "${LAMBDA_DIR}/pyproject.toml" | sed 's/.*"\(.*\)".*/\1/')

# Get values from Terraform outputs
ECR_REPO=$(terraform -chdir=./infra/ecr output -raw ecr_repository_url)
REGION=$(terraform -chdir=./infra/ecr output -raw aws_region)

# Extract registry from repo URL (everything before the first /)
ECR_REGISTRY="${ECR_REPO%%/*}"

echo "==> Logging into ECR..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

echo "==> Building container image..."
docker build \
  --platform=linux/arm64 \
  -t "${ECR_REPO}:${IMAGE_TAG}" \
  "${LAMBDA_DIR}"

echo "==> Pushing to ECR..."
docker push "${ECR_REPO}:${IMAGE_TAG}"

echo "==> Done! Image pushed with tag: ${IMAGE_TAG}"
echo "    Run 'terraform -chdir=./infra/lambda apply -var=\"image_tag=${IMAGE_TAG}\" -var=\"ecr_repository_url=${ECR_REPO}\"' to deploy"
