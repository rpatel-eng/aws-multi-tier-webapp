variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID to deploy resources into"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for web server"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "db_username" {
  default = "webapp_user"
}

variable "db_password" {
  default = "StrongP@ssword123"
}
variable "instance_id" {
  description = "EC2 instance ID to create AMI from"
  type        = string
}

variable "ami_name" {
  description = "Name for the new AMI"
  type        = string
}
variable "lc_name" {
  description = "Launch Configuration name for the ASG"
  default     = "web-lc"
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  default     = "multi-tier-asg"
}
variable "alb_name" {
  description = "Name for the Application Load Balancer"
  default     = "multi-tier-alb"
}
variable "alb_dns" {
  description = "DNS name of the ALB to use as CloudFront origin"
  type        = string
}
