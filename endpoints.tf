# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc_app.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(var.tags, {
    Name = "${var.app_name}-s3-endpoint"
  })
}

# S3 VPC Endpoint Policy
resource "aws_vpc_endpoint_policy" "s3_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::prod-eu-west-1-starport-layer-bucket/*"
        ]
      }
    ]
  })
}

# ECR Interface Endpoints
locals {
  ecr_endpoints = {
    "ecr.api" = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
    "ecr.dkr" = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
    "s3"      = "com.amazonaws.${data.aws_region.current.name}.s3"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  for_each = local.ecr_endpoints

  vpc_id              = module.vpc_app.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = each.key == "s3" ? "Gateway" : "Interface"
  subnet_ids          = each.key == "s3" ? null : module.vpc_app.private_subnets
  security_group_ids  = each.key == "s3" ? null : [aws_security_group.endpoints.id]
  private_dns_enabled = each.key == "s3" ? null : true
  route_table_ids     = each.key == "s3" ? module.vpc_app.private_route_table_ids : null

  tags = merge(var.tags, {
    Name = "${var.app_name}-${each.key}-endpoint"
  })
}

# Security Group for Interface Endpoints
resource "aws_security_group" "endpoints" {
  name        = "${var.app_name}-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc_app.vpc_id

  tags = merge(var.tags, {
    Name = "${var.app_name}-endpoints-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "endpoints" {
  security_group_id = aws_security_group.endpoints.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = module.vpc_app.vpc_cidr_block
  description       = "HTTPS from VPC CIDR"
}

resource "aws_vpc_security_group_egress_rule" "endpoints" {
  security_group_id = aws_security_group.endpoints.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}