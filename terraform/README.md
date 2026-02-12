# Terraform Deployment

This directory contains Terraform configuration to deploy the entire application stack: uses Infrastructure as Code (IaC) to manage:
-   ECR Repositories
-   ECS Cluster
-   IAM Roles
-   Security Groups
-   Task Definitions & Services
-   CloudWatch Logs

## 🚀 How to Use

### Prerequisites
-   [Terraform](https://www.terraform.io/downloads) installed.
-   AWS CLI configured.
-   Docker running.

### 1. Deploy Everything
Run the helper script with the desired environment (`nonprod` or `prod`).
```bash
./deploy.sh nonprod
# OR
./deploy.sh prod
```

### 2. Destroy Everything
To teardown all resources for a specific environment:
```bash
./destroy.sh nonprod
```

## 📝 Configuration
-   **envs/**: Contains environment-specific variables (`nonprod.tfvars`, `prod.tfvars`).
-   **variables.tf**: Input variables.
-   **main.tf**: Defines all AWS resources.
