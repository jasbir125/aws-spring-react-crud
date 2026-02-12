# Walkthrough - React + Spring Boot CRUD on AWS

## Overview
The application has been successfully deployed to AWS ECS Fargate.
It consists of:
1.  **Spring Boot Backend**: Running on port 8080 (internal).
2.  **React Frontend**: Serving static assets and proxying API requests to the backend via Nginx on port 80.

Both containers run within the same ECS Task, allowing them to communicate via `localhost`.

## Accessing the Application
The application is accessible via the Public IP of the running ECS Task.

**Public IP**: 54.224.89.42
**URL**: `http://54.224.89.42`

### Quick Verification
You can verify the backend directly:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"Test Item","description":"Created from CLI"}' http://54.224.89.42/api/items
```

> [!NOTE]
> Since we are using Fargate with a public IP (and no Load Balancer), the IP address will change if the task is stopped and restarted.

## Manual Management Scripts
I've created two scripts to simplify deployment and cleanup:

-   `scripts/deploy.sh`: **Robust deploy.** Checks for (and creates) ECR repos and ECS Cluster if missing. Builds, pushes images, registers task definition, and launches a new task.
-   `scripts/cleanup.sh`: **Cost saving.** Stops all running tasks in the cluster. Does not delete infrastructure (Repos/Cluster) to allow fast redeployment.

### Usage
```bash
# Workflow to save costs and redeploy later:

# 1. Stop everything (Save money)
./scripts/cleanup.sh

# 2. Start fresh (Deploy latest code)
./scripts/deploy.sh
```

**Yes!** You can freely run `cleanup.sh` to stop billing for the compute, and run `deploy.sh` whenever you want to bring the app back up. The scripts are designed to handle this cycle automatically.

## Deployment Details
-   **Cluster**: `spring-react-cluster`
-   **Task Definition**: `spring-react-task`
-   **Network**: VPC `vpc-0ab4cd203b0516a6d`, Subnet `subnet-05105ac1e6d736bbd`.
-   **Security Group**: `sg-05dd3cd20aa5d277d` (Allowed ports 80, 8080).

## Management
To stop the task:
```bash
aws ecs stop-task --cluster spring-react-cluster --task <task-arn>
```

To run a new task:
```bash
aws ecs run-task --cluster spring-react-cluster --task-definition spring-react-task --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[subnet-05105ac1e6d736bbd],securityGroups=[sg-05dd3cd20aa5d277d],assignPublicIp=ENABLED}"
```

## Teardown / Cleanup
To avoid incurring costs, you can remove the created resources:

1.  **Stop the running task**:
    ```bash
    aws ecs list-tasks --cluster spring-react-cluster --query "taskArns[0]" --output text | xargs -I {} aws ecs stop-task --cluster spring-react-cluster --task {}
    ```

2.  **Delete the ECR Repositories** (Optional - if you don't want to keep the images):
    ```bash
    aws ecr delete-repository --repository-name spring-boot-backend --force
    aws ecr delete-repository --repository-name react-frontend --force
    ```

3.  **Delete the ECS Cluster**:
    ```bash
    aws ecs delete-cluster --cluster spring-react-cluster
    ```
