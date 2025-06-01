locals {
  subnets          = cidrsubnets(var.app_cidr, 8, 8, 8)
  subnets_external = cidrsubnets(var.app_cidr, 8, 8, 8, 8)
  subnets_internal = cidrsubnets(var.app_cidr, 8, 8, 8, 8)
}

# iDMZ VPC for Application
module "vpc_app" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.1.2"
  name                 = var.app_name
  cidr                 = var.app_cidr
  azs                  = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  private_subnets      = slice(local.subnets, 0, 3)
  enable_nat_gateway   = false
  create_igw           = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

# Security Group for Application
resource "aws_security_group" "sg_app" {
  name        = "${var.app_name}-sg-app"
  description = "Security group for the feedback application"
  vpc_id      = module.vpc_app.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "inbound_app" {
  security_group_id = aws_security_group.sg_app.id
  ip_protocol       = "tcp"
  from_port         = var.from_port
  to_port           = var.to_port
  cidr_ipv4         = var.app_cidr
  description       = "Inbound rule for feedback application"
  tags              = var.tags
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name                             = "${var.app_name}-nlb"
  internal                         = true
  load_balancer_type               = "network"
  security_groups                  = [aws_security_group.sg_app.id]
  subnets                          = module.vpc_app.private_subnets
  enable_cross_zone_load_balancing = true
  tags                             = var.tags
}

# Target Group
resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-tg"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = module.vpc_app.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = var.tags
}

# Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# VPC Endpoint Service
resource "aws_vpc_endpoint_service" "endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb.arn]
  tags                       = var.tags
}

resource "aws_vpc_endpoint_service_allowed_principal" "allow_me" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.endpoint_service.id
  principal_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

# eDMZ VPC for Internet-Facing Load Balancer
module "external_vpc" {
  count = var.external_enabled ? 1 : 0

  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.1.2"
  name                 = var.external_name
  cidr                 = var.external_cidr
  azs                  = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  public_subnets       = slice(local.subnets, 0, 3)
  enable_nat_gateway   = false
  create_igw           = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

# Security Group for Internet-Facing Load Balancer
resource "aws_security_group" "sg_external" {
  count = var.external_enabled ? 1 : 0

  name        = "${var.external_name}-sg-external"
  description = "Security group for the external load balancer"
  vpc_id      = module.external_vpc[0].vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "inbound_external_app" {
  count = var.external_enabled ? 1 : 0

  security_group_id = aws_security_group.sg_external[0].id
  ip_protocol       = "tcp"
  from_port         = var.from_port
  to_port           = var.to_port
  cidr_ipv4         = var.external_cidr
  description       = "Inbound rule for feedback application"
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "egress_external_app" {
  count = var.external_enabled ? 1 : 0

  security_group_id = aws_security_group.sg_external[0].id
  ip_protocol       = "tcp"
  from_port         = var.from_port
  to_port           = var.to_port
  cidr_ipv4         = var.external_cidr
  description       = "Outbound rule for feedback application"
  tags              = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "inbound_external_http" {
  count = var.external_enabled ? 1 : 0

  security_group_id = aws_security_group.sg_external[0].id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Inbound rule for Load Balancer"
  tags              = var.tags
}

# Application Load Balancer
resource "aws_lb" "alb" {
  count = var.external_enabled ? 1 : 0

  name               = "${var.external_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_external[0].id]
  subnets            = module.external_vpc[0].public_subnets
  tags               = var.tags
}

# Target Group
resource "aws_lb_target_group" "external_target_group" {
  count = var.external_enabled ? 1 : 0

  name        = "${var.external_name}-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.external_vpc[0].vpc_id
  target_type = "ip"
  tags        = var.tags
}

# Listener
resource "aws_lb_listener" "external_front_end" {
  count = var.external_enabled ? 1 : 0

  load_balancer_arn = aws_lb.alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_target_group[0].arn
  }
}

resource "aws_vpc_endpoint" "endpoint" {
  count = var.external_enabled ? 1 : 0

  vpc_id              = module.external_vpc[0].vpc_id
  service_name        = aws_vpc_endpoint_service.endpoint_service.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.external_vpc[0].public_subnets
  security_group_ids  = [aws_security_group.sg_external[0].id]
  private_dns_enabled = false
  tags                = var.tags
}

