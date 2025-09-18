#!/bin/bash
# Usage: ./setup_cloudfront.sh <alb_dns> <distribution_comment>
# Example: ./setup_cloudfront.sh my-alb-1234567890.us-east-1.elb.amazonaws.com "Multi-tier WebApp CDN"

ALB_DNS=$1
DIST_COMMENT=$2

if [ -z "$ALB_DNS" ]; then
    echo "Usage: $0 <alb_dns> <distribution_comment>"
    exit 1
fi

echo "Creating CloudFront distribution for ALB: $ALB_DNS..."

CF_ID=$(aws cloudfront create-distribution \
    --origin-domain-name "$ALB_DNS" \
    --default-root-object index.html \
    --query 'Distribution.Id' \
    --output text)

echo "CloudFront distribution created. ID: $CF_ID"

if [ -n "$DIST_COMMENT" ]; then
    aws cloudfront update-distribution \
        --id "$CF_ID" \
        --distribution-config "{\"Comment\":\"$DIST_COMMENT\"}"
fi

echo "CloudFront setup complete! Distribution ID: $CF_ID"

