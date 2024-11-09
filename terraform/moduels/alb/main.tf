resource "aws_lb" "this" {
  name = "test-alb"

  security_groups = ["sg-05259a8ebb16c8eea"] #手動で作成したSG

  subnets = [
    "subnet-02edb3d7e8c7d09ab", #default
    "subnet-0795e9b0fdb675510" #default
  ]
}

resource "aws_alb_target_group" "this" {
  name        = "test-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0dc6517ff5a5417c1"
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/health/health.html"
    port                = 80
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    matcher             = "200,301,302,304"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = "420"
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn   = "arn:aws:acm:ap-northeast-1:696148199696:certificate/d881ba9f-38de-4f2a-9957-01e1f1b07040" #手動作成

  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
}