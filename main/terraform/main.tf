
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# Network Layer
# -----------------------------

resource "null_resource" "setup_vpc" {
  provisioner "local-exec" {
    command     = "./scripts/setup_vpc.sh ${var.vpc_name} ${var.vpc_cidr}"
    working_dir = "${path.module}"
  }
  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_subnets" {
  depends_on = [null_resource.setup_vpc]

  provisioner "local-exec" {
    command     = "./scripts/setup_subnets.sh ${var.vpc_id} '${join(",", var.public_cidrs)}' '${join(",", var.private_cidrs)}' '${join(",", var.availability_zones)}'"
    working_dir = "${path.module}"
  }
  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_ig" {
  depends_on = [null_resource.setup_vpc]

  provisioner "local-exec" {
    command     = "./scripts/setup_ig.sh ${var.vpc_id}"
    working_dir = "${path.module}"
  }
  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_nat" {
  depends_on = [null_resource.setup_subnets]

  provisioner "local-exec" {
    command     = "./scripts/setup_nat.sh ${var.public_subnet_ids[0]}"
    working_dir = "${path.module}"
  }
  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_route_tables" {
  depends_on = [null_resource.setup_ig, null_resource.setup_nat]

  provisioner "local-exec" {
    command     = "./scripts/setup_route_tables.sh ${var.vpc_id} ${var.igw_id} '${join(",", var.public_subnet_ids)}' '${join(",", var.private_subnet_ids)}' ${var.nat_id}"
    working_dir = "${path.module}"
  }
  triggers = { always_run = timestamp() }
}

# -----------------------------
# Application Layer
# -----------------------------

resource "null_resource" "setup_ami" {
  provisioner "local-exec" {
    command     = "./scripts/setup_ami.sh ${var.instance_id} ${var.ami_name}"
    working_dir = "${path.module}"
  }
  triggers = { instance_id = var.instance_id }
}

resource "null_resource" "setup_asg" {
  depends_on = [null_resource.setup_ami]

  provisioner "local-exec" {
    command     = "./scripts/setup_asg.sh ${var.ami_id} ${var.lc_name} ${var.security_group_id} ${var.key_name} ${var.asg_name} '${join(",", var.public_subnet_ids)}'"
    working_dir = "${path.module}"
  }
  triggers = {
    ami_id   = var.ami_id
    lc_name  = var.lc_name
    asg_name = var.asg_name
  }
}

# -----------------------------
# Load Balancer
# -----------------------------

resource "null_resource" "setup_alb" {
  depends_on = [null_resource.setup_asg]

  provisioner "local-exec" {
    command     = "./scripts/setup_alb.sh ${var.alb_name} '${join(",", var.public_subnet_ids)}' ${var.vpc_id} ${var.security_group_id}"
    working_dir = "${path.module}"
  }
  triggers = {
    alb_name = var.alb_name
  }
}

# -----------------------------
# CloudFront
# -----------------------------

resource "null_resource" "setup_cloudfront" {
  depends_on = [null_resource.setup_alb]

  provisioner "local-exec" {
    command     = "./scripts/setup_cloudfront.sh ${var.alb_dns} '${var.cloudfront_comment}'"
    working_dir = "${path.module}"
  }
  triggers = {
    alb_dns = var.alb_dns
  }
}

