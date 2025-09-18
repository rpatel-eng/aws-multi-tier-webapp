# Deployment Steps for AWS Multi-Tier Web Application

## **1. Prerequisites**

1. **AWS CLI** installed and configured with proper IAM permissions.
2. **Terraform v1.5+** installed.
3. **Bash shell** (Linux/Mac) or WSL (Windows).
4. Project folder structure:

```
aws-multi-tier-webapp/
├── scripts/
│   ├── setup_vpc.sh
│   ├── setup_subnets.sh
│   ├── setup_ig.sh
│   ├── setup_nat.sh
│   ├── setup_route_tables.sh
│   ├── setup_ami.sh
│   ├── setup_asg.sh
│   ├── setup_alb.sh
│   └── setup_cloudfront.sh
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── alb.tf
│   ├── cloudfront.tf
│   └── outputs.tf
├── webapp/
│   ├── createUser.html
│   └── insert.php
└── README.md
```

---

## **2. Network Layer Setup**

### **Step 2.1: Create VPC**

```bash
./scripts/setup_vpc.sh my-vpc 10.0.0.0/16
VPC_ID=$(cat scripts/vpc_id.txt)
```

### **Step 2.2: Create Public and Private Subnets**

```bash
./scripts/setup_subnets.sh $VPC_ID "10.0.1.0/24,10.0.2.0/24" "10.0.101.0/24,10.0.102.0/24" "us-east-1a,us-east-1b"
PUBLIC_SUBNET_IDS=$(cat scripts/public_subnets.txt)
PRIVATE_SUBNET_IDS=$(cat scripts/private_subnets.txt)
```

### **Step 2.3: Create Internet Gateway**

```bash
./scripts/setup_ig.sh $VPC_ID
IGW_ID=$(cat scripts/igw_id.txt)
```

### **Step 2.4: Create NAT Gateway**

```bash
# Using the first public subnet for NAT
FIRST_PUBLIC_SUBNET=$(echo $PUBLIC_SUBNET_IDS | cut -d' ' -f1)
./scripts/setup_nat.sh $FIRST_PUBLIC_SUBNET
NAT_ID=$(cat scripts/nat_id.txt)
```

### **Step 2.5: Configure Route Tables**

```bash
./scripts/setup_route_tables.sh $VPC_ID $IGW_ID "$PUBLIC_SUBNET_IDS" "$PRIVATE_SUBNET_IDS" $NAT_ID
```

---

## **3. EC2 and AMI Setup**

### **Step 3.1: Launch EC2 instance manually or via Terraform**

* Use **existing instance ID** or Terraform to create one.
* Ensure Apache, PHP, and MySQL packages are installed.

### **Step 3.2: Create AMI from EC2**

```bash
./scripts/setup_ami.sh <instance_id> linuxmysqlweb
AMI_ID=$(cat ami_id.txt)
```

---

## **4. Auto Scaling Group Setup**

```bash
./scripts/setup_asg.sh $AMI_ID web-lc <security_group_id> <key_name> multi-tier-asg "$PUBLIC_SUBNET_IDS"
```

* Parameters:

  * `$AMI_ID` – AMI created in Step 3
  * `web-lc` – Launch Configuration name
  * `<security_group_id>` – Security group for web servers
  * `<key_name>` – Key pair for SSH access
  * `multi-tier-asg` – ASG name
  * `$PUBLIC_SUBNET_IDS` – Comma-separated list of public subnets

---

## **5. Application Load Balancer (ALB) Setup**

```bash
./scripts/setup_alb.sh multi-tier-alb "$PUBLIC_SUBNET_IDS" $VPC_ID "<security_group_id>"
```

* Parameters:

  * `multi-tier-alb` – ALB name
  * `$PUBLIC_SUBNET_IDS` – Comma-separated list of public subnets
  * `$VPC_ID` – VPC ID
  * `<security_group_id>` – Security group for ALB

---

## **6. CloudFront Setup**

```bash
./scripts/setup_cloudfront.sh <alb_dns> "Multi-tier WebApp CDN"
```

* `<alb_dns>` – DNS name of the ALB created in Step 5.

---

## **7. Terraform Deployment (Optional / Integrated)**

1. Update **variables.tf** with all the parameters:

```hcl
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ami_id" {}
variable "lc_name" {}
variable "asg_name" {}
variable "key_name" {}
variable "alb_name" {}
variable "alb_dns" {}
```

2. Run Terraform:

```bash
terraform init
terraform plan \
  -var="vpc_id=$VPC_ID" \
  -var="public_subnet_ids=$PUBLIC_SUBNET_IDS" \
  -var="private_subnet_ids=$PRIVATE_SUBNET_IDS" \
  -var="ami_id=$AMI_ID" \
  -var="lc_name=web-lc" \
  -var="asg_name=multi-tier-asg" \
  -var="key_name=<key_name>" \
  -var="alb_name=multi-tier-alb" \
  -var="alb_dns=<alb_dns>"
terraform apply
```

---

## **8. Security Highlights**

* VPC **isolates private subnets** for backend servers.
* NAT Gateway provides **controlled internet access** to private subnets.
* Security Groups restrict traffic to **HTTP/HTTPS** and **SSH** only.
* CloudFront **caches and protects content** at edge locations.
* AMI creation ensures **immutable server images** for scaling.

---

## **9. Testing**

1. Visit **CloudFront URL** to verify the web app is live.
2. Check **ASG** in AWS console; increase load to see new instances launched.
3. Confirm **RDS connectivity** from web instances in private subnets.
4. Ensure **NAT Gateway** allows outbound internet access for updates.

---

## **10. Notes**

* Replace all `<placeholders>` with actual IDs and DNS values.
* All scripts are **reusable and parameterized** for multiple environments.
* This workflow supports **multi-AZ, multi-tier scaling, and secure architecture**.

---
