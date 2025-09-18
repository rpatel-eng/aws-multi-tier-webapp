#!/bin/bash
# Usage: ./setup_route_tables.sh <vpc_id> <igw_id> <public_subnet_ids> <private_subnet_ids> <nat_id>
# Example: ./setup_route_tables.sh vpc-0abc igw-0abc "subnet-1,subnet-2" "subnet-101,subnet-102" nat-0abc

VPC_ID=$1
IGW_ID=$2
PUBLIC_SUBNET_IDS=(${3//,/ })
PRIVATE_SUBNET_IDS=(${4//,/ })
NAT_ID=$5

# Public Route Table
PUB_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Public Route Table: $PUB_RT"

for SUBNET in ${PUBLIC_SUBNET_IDS[@]}; do
    aws ec2 associate-route-table --subnet-id $SUBNET --route-table-id $PUB_RT
done

aws ec2 create-route --route-table-id $PUB_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Private Route Table
PRI_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Private Route Table: $PRI_RT"

for SUBNET in ${PRIVATE_SUBNET_IDS[@]}; do
    aws ec2 associate-route-table --subnet-id $SUBNET --route-table-id $PRI_RT
done

aws ec2 create-route --route-table-id $PRI_RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_ID

echo "Route tables configured."

