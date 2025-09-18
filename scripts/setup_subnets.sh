#!/bin/bash
# Usage: ./setup_subnets.sh <vpc_id> <public_cidr1,public_cidr2> <private_cidr1,private_cidr2> <az1,az2>
# Example: ./setup_subnets.sh vpc-0a1b2c3d4e5f6g7h8 "10.0.1.0/24,10.0.2.0/24" "10.0.101.0/24,10.0.102.0/24" "us-east-1a,us-east-1b"

VPC_ID=$1
PUBLIC_CIDRS=(${2//,/ })
PRIVATE_CIDRS=(${3//,/ })
AZS=(${4//,/ })

if [ -z "$VPC_ID" ] || [ ${#PUBLIC_CIDRS[@]} -ne ${#AZS[@]} ] || [ ${#PRIVATE_CIDRS[@]} -ne ${#AZS[@]} ]; then
    echo "Usage: $0 <vpc_id> <public_cidr1,public_cidr2> <private_cidr1,private_cidr2> <az1,az2>"
    exit 1
fi

PUBLIC_SUBNET_IDS=()
PRIVATE_SUBNET_IDS=()

for i in ${!AZS[@]}; do
    PUB_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block ${PUBLIC_CIDRS[$i]} --availability-zone ${AZS[$i]} \
        --query 'Subnet.SubnetId' --output text)
    echo "Public Subnet created: $PUB_ID"
    PUBLIC_SUBNET_IDS+=($PUB_ID)

    PRI_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block ${PRIVATE_CIDRS[$i]} --availability-zone ${AZS[$i]} \
        --query 'Subnet.SubnetId' --output text)
    echo "Private Subnet created: $PRI_ID"
    PRIVATE_SUBNET_IDS+=($PRI_ID)
done

echo "Public Subnets: ${PUBLIC_SUBNET_IDS[@]}" > public_subnets.txt
echo "Private Subnets: ${PRIVATE_SUBNET_IDS[@]}" > private_subnets.txt

