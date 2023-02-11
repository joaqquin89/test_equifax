
module "loadbalancer-sg" {
  source       = "../security_groups"
  name         = "ClassicLBsg"
  description  = "sg allow incomming traffic in ports 80 and 443"
  tags_sg  =  "${var.tags_loadbancer}"
  vpc_id       = "${var.vpc_id}"
  ingress_cidr = ["0.0.0.0/0"]
  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"

    }
  ]
}

resource "aws_lb" "alb" {
  name            = var.elb_name
  load_balancer_type = "application"
  subnets         = var.subnets_id
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "group_target" {
  name     = "${var.elb_name}-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_lb_listener" "listener_http" {
  depends_on = [
    aws_lb_target_group.group_target
  ]
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.group_target.arn}"
    type             = "forward"
  }
}