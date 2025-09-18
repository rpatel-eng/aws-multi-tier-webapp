resource "null_resource" "setup_alb" {
  provisioner "local-exec" {
    command = "./scripts/setup_alb.sh ${var.alb_name} '${join(",", var.public_subnet_ids)}' ${var.vpc_id} '${aws_security_group.web_sg.id}'"
    working_dir = "${path.module}"
  }

  triggers = {
    alb_name       = var.alb_name
    public_subnets = join(",", var.public_subnet_ids)
    vpc_id         = var.vpc_id
    sg_id          = aws_security_group.web_sg.id
  }
}

resource "aws_lb_target_group" "web" {
  name        = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

