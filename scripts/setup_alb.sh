#!/bin/bash
# Usage: ./setup_alb.sh <alb_name> <subnet_ids> <vpc_id> <security_group_ids>
# Example:
# ./setup_alb.sh my-alb "subnet-0abcde1234567890,subnet-0fghij1234567890" vpc-0a1b2c3d4e5f6g7h8 "sg-0abc123456789,sg-0def456789"

ALB_NAME=$1
SUBNET_IDS=$2
VPC_ID=$3
SG_IDS=$4

if [ -z "$ALB_NAME" ] || [ -z "$SUBNET_IDS" ] || [ -z "$VPC_ID" ] || [ -z "$SG_IDS" ]; then
    echo "Usage: $0 <alb_name> <subnet_ids> <vpc_id> <security_group_ids>"
    exit 1
fi

echo "Creating Application Load Balancer $ALB_NAME..."
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name "$ALB_NAME" \
    --subnets $(echo $SUBNET_IDS | tr ',' ' ') \
    --security-groups $(echo $SG_IDS | tr ',' ' ') \
    --scheme internet-facing \
    --type application \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

echo "ALB created. ARN: $ALB_ARN"

echo "Creating Target Group for ALB..."
TG_ARN=$(aws elbv2 create-target-group \
    --name "${ALB_NAME}-tg" \
    --protocol HTTP \
    --port 80 \
    --vpc-id "$VPC_ID" \
    --target-type instance \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "Target Group ARN: $TG_ARN"

echo "Creating Listener..."
aws elbv2 create-listener \
    --load-balancer-arn "$ALB_ARN" \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn="$TG_ARN"

echo "ALB $ALB_NAME setup complete!"

