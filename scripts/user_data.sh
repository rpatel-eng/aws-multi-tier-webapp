#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd mysql

systemctl enable httpd
systemctl start httpd

# Deploy web files (replace BUCKET_NAME with S3 bucket containing web files)
aws s3 cp s3://multi-tier-webapp-bucket/web/ /var/www/html/ --recursive
chown -R apache:apache /var/www/html

# Set environment variables
echo "export DB_HOST=multi-tier-webapp-db.abcdefghijkl.us-east-1.rds.amazonaws.com" >> /etc/profile
echo "export DB_NAME=multi_tier_app_db" >> /etc/profile
echo "export DB_USER=webapp_user" >> /etc/profile
echo "export DB_PASSWORD=StrongP@ssword123" >> /etc/profile
source /etc/profile

