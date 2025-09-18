#!/bin/bash
# Usage: ./setup_ami.sh <instance_id> <ami_name>
# Example: ./setup_ami.sh i-094aadd9c54a733ed linuxmysqlweb

INSTANCE_ID=$1
AMI_NAME=$2

if [ -z "$INSTANCE_ID" ] || [ -z "$AMI_NAME" ]; then
    echo "Usage: $0 <instance_id> <ami_name>"
    exit 1
fi

echo "Creating AMI from instance $INSTANCE_ID with name $AMI_NAME..."

AMI_ID=$(aws ec2 create-image \
    --instance-id "$INSTANCE_ID" \
    --name "$AMI_NAME" \
    --no-reboot \
    --query 'ImageId' \
    --output text)

echo "AMI creation initiated. AMI ID: $AMI_ID"

echo "Waiting until AMI is available..."
aws ec2 wait image-available --image-ids "$AMI_ID"

echo "AMI $AMI_NAME ($AMI_ID) is now available."

