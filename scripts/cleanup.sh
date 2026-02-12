#!/bin/bash

CLUSTER_NAME="spring-react-cluster"

echo "Stopping all tasks in cluster: $CLUSTER_NAME"

# Get all running task ARNs
TASK_ARNS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query "taskArns[]" --output text)

if [ "$TASK_ARNS" == "None" ] || [ -z "$TASK_ARNS" ]; then
    echo "No running tasks found."
else
    # Stop each task
    for ARN in $TASK_ARNS; do
        echo "Stopping task: $ARN"
        aws ecs stop-task --cluster $CLUSTER_NAME --task $ARN
    done
    echo "All tasks stop command issued."
fi

echo "Note: This script only stops running tasks to save compute costs."
echo "Infrastructure (ECR Repos, ECS Cluster, Task Definitions) persists for future deployments."
