#!/bin/bash
set -e

# Check argument
if [ -z "$1" ]; then
    echo "Usage: ./destroy.sh <env>"
    echo "Example: ./destroy.sh nonprod"
    exit 1
fi

ENV=$1
VAR_FILE="envs/${ENV}.tfvars"

if [ ! -f "$VAR_FILE" ]; then
    echo "Error: Var file $VAR_FILE does not exist."
    exit 1
fi

echo "💥 Destroying all resources via Terraform for Environment: $ENV..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed."
    exit 1
fi

echo "Selecting Workspace: $ENV"
terraform workspace select $ENV || (echo "Workspace $ENV does not exist." && exit 1)

# Destroy everything
terraform destroy -var-file="$VAR_FILE" -auto-approve

echo "✅ All resources destroyed ($ENV)."
