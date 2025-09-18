#!/bin/bash
# Usage: ./setup_asg.sh <ami_id> <lc_name> <security_group_id> <key_name> <asg_name> <subnet_ids>
# Example:
# ./setup_asg.sh ami-0abcdef1234567890 web-lc sg-0abc123456789 keypair-portfolio multi-tier-asg "subnet-0abcde1234567890,subnet-0fghij1234567890"

AMI_ID=$1
LC_NAME=$2
SG_ID=$3
KEY_NAME=$4
ASG_NAME=$5
SUBNET_IDS=$6  # comma-separated list

if [ -z "$AMI_ID" ] || [ -z "$LC_NAME" ] || [ -z "$SG_ID" ] || [ -z "$KEY_NAME" ] || [ -z "$ASG_NAME" ] || [ -z "$SUBNET_IDS" ]; then
    echo "Usage: $0 <ami_id> <lc_name> <security_group_id> <key_name> <asg_name> <subnet_ids>"
    exit 1
fi

echo "Creating Launch Configuration $LC_NAME..."
aws autoscaling create-launch-configuration \
    --launch-configuration-name "$LC_NAME" \
    --image-id "$AMI_ID" \
    --instance-type t2.micro \
    --security-groups "$SG_ID" \
    --key-name "$KEY_NAME"

echo "Creating Auto Scaling Group $ASG_NAME..."
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name "$ASG_NAME" \
    --launch-configuration-name "$LC_NAME" \
    --min-size 1 \
    --max-size 3 \
    --desired-capacity 2 \
    --vpc-zone-identifier "$SUBNET_IDS"

echo "ASG $ASG_NAME created successfully!"

