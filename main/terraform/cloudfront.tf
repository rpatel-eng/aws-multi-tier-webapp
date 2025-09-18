resource "null_resource" "setup_cloudfront" {
  provisioner "local-exec" {
    command     = "./scripts/setup_cloudfront.sh ${var.alb_dns} 'Multi-tier WebApp CDN'"
    working_dir = "${path.module}"
  }

  triggers = {
    alb_dns = var.alb_dns
  }
}
