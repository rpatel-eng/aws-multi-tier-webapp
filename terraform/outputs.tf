output "vpc_id" { value = var.vpc_id }
output "public_subnets" { value = var.public_subnet_ids }
output "private_subnets" { value = var.private_subnet_ids }
output "alb_dns" { value = aws_lb.app.dns_name }
output "cloudfront_domain" { value = aws_cloudfront_distribution.cdn.domain_name }
output "rds_endpoint" { value = aws_db_instance.mysql.endpoint }

