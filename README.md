# **AWS Multi-Tier Web Application**

## Project Overview
This project demonstrates a professional **AWS multi-tier web application**, designed for high availability, security, and scalability. Users can submit their name and email through a PHP form, which stores the data in a **MySQL RDS database**.

* **VPC with public and private subnets**
* **NAT Gateway** for controlled outbound access
* **EC2 instances** running Apache, PHP, and MySQL
* **Auto Scaling Group (ASG)** for horizontal scaling
* **Application Load Balancer (ALB)**
* **CloudFront** CDN for caching and edge security
* **Parameterized deployment scripts** for modular and reusable deployments

## Architecture Overview
**Three-Tier Architecture**:

1. **Presentation Layer**: `createUser.html` form `insert.php` (handles user submission to RDS), served via CloudFront + ALB
2. **Application Layer**: EC2 instances running PHP & Apache, Auto Scaling Group
3. **Database Layer**: RDS MySQL in private subnet, accessible only from web servers
4. **Scripts**: Parameterized shell scripts to provision **network, EC2, scaling, and CDN**
5. **Terraform**: Orchestrates all scripts and resources in a single deployment
---

## Project Files

```
aws-multi-tier-webapp/
├── scripts/           # Deployment and setup scripts (VPC, subnets, NAT, AMI, ASG, ALB, CloudFront)
├── terraform/         # Terraform modules calling the scripts
├── webapp/            # PHP web application: createUser.html, insert.php
├── deployment_steps.md # Detailed deployment instructions
└── README.md

```

---

## Deployment Steps

See **deployment\_steps.md** for a **step-by-step guide**, including:

1. Network setup: VPC, subnets, NAT, IG, and route tables
2. EC2 instance setup and AMI creation
3. Auto Scaling Group configuration
4. Application Load Balancer creation
5. CloudFront distribution setup

All scripts and Terraform modules are **parameterized for reusable deployments**.

---

## Security Highlights

* Private subnets isolate backend servers
* NAT Gateway provides controlled outbound internet access
* Security groups restrict access to **HTTP/HTTPS** and **SSH**
* CloudFront provides **edge caching and DDoS protection**
* AMI ensures **immutable server images** for scaling

---

## Terraform Integration

* Terraform calls **all deployment scripts** via `null_resource`
* All key parameters (VPC ID, subnets, AMI, ASG, ALB, CloudFront) are configurable
* Allows **fully automated, multi-AZ, multi-tier deployment**

---

## Usage Notes

* Replace all placeholders (`<vpc_id>`, `<alb_dns>`, `<key_name>`, `<security_group_id>`) with actual values
* Web app logic remains **exactly as in your original project**
* Designed for **professional, scalable, secure deployments**
