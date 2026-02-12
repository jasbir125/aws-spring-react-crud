#!/bin/bash
set -e # Exit immediately if a command fails

# Check argument
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh <env>"
    echo "Example: ./deploy.sh nonprod"
    exit 1
fi

ENV=$1
VAR_FILE="envs/${ENV}.tfvars"

if [ ! -f "$VAR_FILE" ]; then
    echo "Error: Var file $VAR_FILE does not exist."
    exit 1
fi

echo "🚀 Starting Deployment for Environment: $ENV"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed. Please install it first."
    exit 1
fi

# 1. Initialize Terraform
echo "Initializing Terraform..."
terraform init

# 2. Workspace Management
echo "--------------------------------------------------"
echo "Selecting Workspace: $ENV"
terraform workspace select $ENV || terraform workspace new $ENV

# 3. Create ECR Repositories first
echo "--------------------------------------------------"
echo "Creating ECR Repositories..."
terraform apply -var-file="$VAR_FILE" -target=aws_ecr_repository.backend -target=aws_ecr_repository.frontend -auto-approve

# 4. Build and Push Docker Images
echo "--------------------------------------------------"
echo "Building and Pushing Images..."

# Get Repository URLs from Terraform Output
# Note: terraform output only shows values after they are applied/refreshed
BACKEND_REPO=$(terraform output -raw ecr_backend_url)
FRONTEND_REPO=$(terraform output -raw ecr_frontend_url)
AWS_REGION="us-east-1" # Defaulting to us-east-1 as per vars

# ECR Login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $BACKEND_REPO

# Build Backend
echo "Building Backend..."
cd ../backend
docker build --platform linux/amd64 -t $BACKEND_REPO:latest .
docker push $BACKEND_REPO:latest
cd ../terraform

# Build Frontend
echo "Building Frontend..."
cd ../frontend
docker build --platform linux/amd64 -t $FRONTEND_REPO:latest .
docker push $FRONTEND_REPO:latest
cd ../terraform

# 5. Deploy Infrastructure (Cluster, Service, Task Def)
echo "--------------------------------------------------"
echo "Deploying Application Infrastructure..."
terraform apply -var-file="$VAR_FILE" -auto-approve

echo "--------------------------------------------------"
echo "✅ Deployment Complete ($ENV)!"
echo "Cluster: $(terraform output -raw cluster_name)"
echo "Service: $(terraform output -raw service_name)"
echo "Note: It may take a minute for the task to start and get a Public IP."
echo "You can view the specific task IP in the AWS Console under ECS -> Clusters -> Tasks."
