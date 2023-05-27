
# application load balancer craetion

resource "aws_alb" "node_appliaction_load_balancer" {
  name               = "node-test-alb"
  load_balancer_type = "application"
  # referencing subnets
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]

  #refenrencing the sucurity group
  security_groups = ["${aws_security_group.node-alb-sg.id}"]




}

resource "aws_security_group" "node-alb-sg" {

  name = "node_app_loadblancer_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# alb target group

resource "aws_lb_target_group" "node-app-target-group" {
  name        = "nodeAppTargetGroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }

}


resource "aws_lb_listener" "node-app-lb-listner" {
  load_balancer_arn = aws_alb.node_appliaction_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node-app-target-group.arn
  }
}
