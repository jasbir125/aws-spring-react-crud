#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="359082855184"
ECR_REPO_BACKEND="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/spring-boot-backend"
ECR_REPO_BACKEND_NAME="spring-boot-backend"
ECR_REPO_FRONTEND="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/react-frontend"
ECR_REPO_FRONTEND_NAME="react-frontend"
CLUSTER_NAME="spring-react-cluster"
TASK_FAMILY="spring-react-task"
SUBNET_ID="subnet-05105ac1e6d736bbd"
SECURITY_GROUP_ID="sg-05dd3cd20aa5d277d"

echo "Using Configuration:"
echo "Region: $AWS_REGION"
echo "Cluster: $CLUSTER_NAME"

# 1. Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Check/Create Backend Repo
echo "Checking Backend Repo: $ECR_REPO_BACKEND_NAME"
aws ecr describe-repositories --repository-names $ECR_REPO_BACKEND_NAME > /dev/null 2>&1 || \
    (echo "Creating repo..." && aws ecr create-repository --repository-name $ECR_REPO_BACKEND_NAME)

# Check/Create Frontend Repo
echo "Checking Frontend Repo: $ECR_REPO_FRONTEND_NAME"
aws ecr describe-repositories --repository-names $ECR_REPO_FRONTEND_NAME > /dev/null 2>&1 || \
    (echo "Creating repo..." && aws ecr create-repository --repository-name $ECR_REPO_FRONTEND_NAME)

# 2. Build and Push Backend
echo "Building Backend (linux/amd64)..."
cd backend
docker build --platform linux/amd64 -t spring-boot-backend .
docker tag spring-boot-backend:latest $ECR_REPO_BACKEND:latest
echo "Pushing Backend..."
docker push $ECR_REPO_BACKEND:latest
cd ..

# 3. Build and Push Frontend
echo "Building Frontend (linux/amd64)..."
cd frontend
docker build --platform linux/amd64 -t react-frontend .
docker tag react-frontend:latest $ECR_REPO_FRONTEND:latest
echo "Pushing Frontend..."
docker push $ECR_REPO_FRONTEND:latest
cd ..

# 4. Check/Create ECS Cluster
echo "Checking ECS Cluster: $CLUSTER_NAME"
aws ecs describe-clusters --clusters $CLUSTER_NAME --query "clusters[0].status" --output text | grep "^ACTIVE$" > /dev/null 2>&1 || \
    (echo "Creating cluster..." && aws ecs create-cluster --cluster-name $CLUSTER_NAME)

# 5. Register Task Definition
TASK_DEF_PATH="./ecs-task-def.json"
if [ -f "$TASK_DEF_PATH" ]; then
    echo "Registering Task Definition from $TASK_DEF_PATH..."
    aws ecs register-task-definition --cli-input-json file://$TASK_DEF_PATH
else
    echo "Warning: $TASK_DEF_PATH not found. Skipping registration."
fi

# 6. Run Task
echo "Launching ECS Task..."
TASK_ARN=$(aws ecs run-task \
    --cluster $CLUSTER_NAME \
    --task-definition $TASK_FAMILY \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --query "tasks[0].taskArn" --output text)

echo "Task Launched: $TASK_ARN"
echo "Waiting for task to be RUNNING..."

# 7. Wait for Task to Run and Get IP
aws ecs wait tasks-running --cluster $CLUSTER_NAME --tasks $TASK_ARN

ENI_ID=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].Association.PublicIp" --output text)

echo "--------------------------------------------------"
echo "Deployment Complete!"
echo "Backend & Frontend are running."
echo "Public request URL: http://$PUBLIC_IP"
echo "Verify API: curl -I http://$PUBLIC_IP/api/items"
echo "--------------------------------------------------"
