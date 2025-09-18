resource "null_resource" "setup_vpc" {
  provisioner "local-exec" {
    command     = "./scripts/setup_vpc.sh my-vpc 10.0.0.0/16"
    working_dir = "${path.module}"
  }

  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_subnets" {
  depends_on  = [null_resource.setup_vpc]

  provisioner "local-exec" {
    command     = "./scripts/setup_subnets.sh <vpc_id_placeholder> '10.0.1.0/24,10.0.2.0/24' '10.0.101.0/24,10.0.102.0/24' 'us-east-1a,us-east-1b'"
    working_dir = "${path.module}"
  }

  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_ig" {
  depends_on = [null_resource.setup_vpc]

  provisioner "local-exec" {
    command     = "./scripts/setup_ig.sh <vpc_id_placeholder>"
    working_dir = "${path.module}"
  }

  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_nat" {
  depends_on = [null_resource.setup_subnets]

  provisioner "local-exec" {
    command     = "./scripts/setup_nat.sh <first_public_subnet_id>"
    working_dir = "${path.module}"
  }

  triggers = { always_run = timestamp() }
}

resource "null_resource" "setup_route_tables" {
  depends_on = [null_resource.setup_ig, null_resource.setup_nat]

  provisioner "local-exec" {
    command     = "./scripts/setup_route_tables.sh <vpc_id_placeholder> <igw_id> '<public_subnet_ids>' '<private_subnet_ids>' <nat_id>"
    working_dir = "${path.module}"
  }

  triggers = { always_run = timestamp() }
}

