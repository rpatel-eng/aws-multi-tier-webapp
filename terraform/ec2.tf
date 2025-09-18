resource "aws_launch_configuration" "web" {
  name            = "web-lc"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  user_data       = file("../scripts/user_data.sh")
}

resource "null_resource" "setup_asg" {
  provisioner "local-exec" {
    command = "./scripts/setup_asg.sh ${var.ami_id} ${var.lc_name} ${aws_security_group.web_sg.id} ${var.key_name} ${var.asg_name} '${join(",", var.public_subnet_ids)}'"
    working_dir = "${path.module}"
  }

  triggers = {
    ami_id        = var.ami_id
    lc_name       = var.lc_name
    key_name      = var.key_name
    asg_name      = var.asg_name
    public_subnets = join(",", var.public_subnet_ids)
  }
}

# Call setup_ami.sh after instance is up
resource "null_resource" "create_ami" {
  provisioner "local-exec" {
    command     = "./scripts/setup_ami.sh ${var.instance_id} ${var.ami_name}"
    working_dir = "${path.module}"
  }

  triggers = {
    instance_id = var.instance_id
    ami_name    = var.ami_name
  }
}

