resource "aws_ecs_cluster" "my-node_app_cluster" {
  name = "my_node_app_cluster"


}

resource "aws_ecs_service" "my-node-app-service" {

  name            = "my_node_app_service"
  cluster         = aws_ecs_cluster.my-node_app_cluster.id
  task_definition = aws_ecs_task_definition.my-node-app-task.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.ecs-alb-only-sg.id}"]
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.node-app-target-group.arn
    container_name   = aws_ecs_task_definition.my-node-app-task.family
    container_port   = 3000
  }


}


#ecs security group because ecs want to acess alb traffic only

resource "aws_security_group" "ecs-alb-only-sg" {
  name = "ecs-alb-only-sg"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = ["${aws_security_group.node-alb-sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}



resource "aws_ecs_task_definition" "my-node-app-task" {
  family = "my_node_app_task"
  container_definitions = jsonencode([
    {
      "name" : "my_node_app_container",
      "image" : "${data.aws_ecr_repository.my-node-repo.repository_url}:latest",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort" : 3000
        }
      ],
      "memory" : 500,
      "cpu" : 256

    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn
}


output "sa" {
  value = aws_ecs_task_definition.my-node-app-task.arn
}
output "wa" {
  value = aws_ecs_task_definition.my-node-app-task.tags
}
