#!/bin/bash
# Usage: ./setup_ig.sh <vpc_id>
VPC_ID=$1

if [ -z "$VPC_ID" ]; then
    echo "Usage: $0 <vpc_id>"
    exit 1
fi

echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Internet Gateway created and attached. ID: $IGW_ID"
echo $IGW_ID > igw_id.txt

