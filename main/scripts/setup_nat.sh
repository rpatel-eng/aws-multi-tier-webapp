#!/bin/bash
# Usage: ./setup_nat.sh <public_subnet_id>
PUB_SUBNET=$1

if [ -z "$PUB_SUBNET" ]; then
    echo "Usage: $0 <public_subnet_id>"
    exit 1
fi

EIP_ALLOC=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
NAT_ID=$(aws ec2 create-nat-gateway --subnet-id $PUB_SUBNET --allocation-id $EIP_ALLOC --query 'NatGateway.NatGatewayId' --output text)

echo "Waiting for NAT gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_ID
echo "NAT Gateway ID: $NAT_ID"
echo $NAT_ID > nat_id.txt

