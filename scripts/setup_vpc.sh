#!/bin/bash
# Usage: ./setup_vpc.sh <vpc_name> <cidr_block>
# Example: ./setup_vpc.sh my-vpc 10.0.0.0/16

VPC_NAME=$1
CIDR_BLOCK=$2

if [ -z "$VPC_NAME" ] || [ -z "$CIDR_BLOCK" ]; then
    echo "Usage: $0 <vpc_name> <cidr_block>"
    exit 1
fi

echo "Creating VPC $VPC_NAME with CIDR $CIDR_BLOCK..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block "$CIDR_BLOCK" \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC created. ID: $VPC_ID"
echo $VPC_ID > vpc_id.txt

