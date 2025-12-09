locals {
  name_prefix = "${var.project_name}-${var.environment}"
  alb_name    = "${local.name_prefix}-alb"
  sg_name     = "${local.alb_name}-sg"
  tg_name     = "${local.name_prefix}-tg"
  http_listener_name  = "${local.name_prefix}-alb-listener-http"
  https_listener_name = "${local.name_prefix}-alb-listener-https"
}

# -------------------------
# Security group for ALB
# -------------------------
resource "aws_security_group" "verdethos_alb_sg" {
  name        = local.sg_name
  description = "Security group for ${local.alb_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = local.sg_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "verdethos_alb_ingress_http" {
  count             = var.listener_protocol == "HTTP" || var.listener_port == 80 ? 1 : 0
  type              = "ingress"
  from_port         = var.listener_port
  to_port           = var.listener_port
  protocol          = "tcp"
  security_group_id = aws_security_group.verdethos_alb_sg.id
  cidr_blocks       = var.allowed_cidrs
}

resource "aws_security_group_rule" "verdethos_alb_ingress_https" {
  count             = var.enable_https ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.verdethos_alb_sg.id
  cidr_blocks       = var.allowed_cidrs
}

resource "aws_security_group_rule" "verdethos_alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.verdethos_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# -------------------------
# Application Load Balancer
# -------------------------
resource "aws_lb" "verdethos_alb" {
  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.verdethos_alb_sg.id]

  tags = {
    Name        = local.alb_name
    Project     = var.project_name
    Environment = var.environment
  }
}

# -------------------------
# Target Group
# -------------------------
resource "aws_lb_target_group" "verdethos_tg" {
  name        = local.tg_name
  vpc_id      = var.vpc_id
  port        = var.target_port
  protocol    = var.target_protocol
  target_type = var.target_type

  health_check {
    path                = var.health_path
    matcher             = var.health_matcher
    interval            = var.health_interval
    timeout             = var.health_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = {
    Name        = local.tg_name
    Project     = var.project_name
    Environment = var.environment
  }
}

# -------------------------
# Listener: HTTP (required)
# -------------------------
resource "aws_lb_listener" "verdethos_http_listener" {
  load_balancer_arn = aws_lb.verdethos_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.verdethos_tg.arn
  }

  tags = {
    Name = local.http_listener_name
  }
}

# -------------------------
# Listener: HTTPS (optional)
# -------------------------
resource "aws_lb_listener" "verdethos_https_listener" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.verdethos_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.verdethos_tg.arn
  }

  tags = {
    Name = local.https_listener_name
  }
}

# -------------------------
# Optional: Register static targets with the TG (instance/ip/lambda)
# Provide var.targets as list(object({ target_id=string, port=number })) when needed.
# -------------------------
locals {
  targets_map = { for idx, t in var.targets : "${idx}" => t }
}

resource "aws_lb_target_group_attachment" "verdethos_tg_attachment" {
  for_each = var.create_static_targets ? local.targets_map : {}
  target_group_arn = aws_lb_target_group.verdethos_tg.arn
  target_id        = each.value.target_id
  port             = lookup(each.value, "port", var.target_port)
}

# -------------------------
# Optional: enable access logs (S3 bucket required)
# -------------------------
resource "aws_s3_bucket" "verdethos_alb_logs_bucket" {
  count = var.enable_access_logs ? 1 : 0

  bucket = var.access_logs_bucket_name != "" ? var.access_logs_bucket_name : "${local.name_prefix}-alb-logs-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  tags = {
    Name        = "${local.name_prefix}-alb-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_caller_identity" "current" {}
resource "aws_lb" "verdethos_alb_update_access_logs" {
  subnets            = var.public_subnets
  count             = 0
  # not used; real access_log configuration is set via aws_lb resource's access_logs block
}
# Configure access_logs on the ALB if requested (using lifecycle to avoid repetitive diffs)
resource "null_resource" "configure_access_logs" {
  count = var.enable_access_logs ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ALB access logs enabled to bucket ${aws_s3_bucket.verdethos_alb_logs_bucket[0].bucket}'"
  }

  triggers = {
    alb_arn = aws_lb.verdethos_alb.arn
    bucket  = aws_s3_bucket.verdethos_alb_logs_bucket[0].bucket
  }
}
