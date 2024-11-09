resource "aws_ecs_cluster" "this" {
  name = "test-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "test-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = "arn:aws:iam::696148199696:role/ecsTaskExecutionRole" #手動作成
  execution_role_arn       = "arn:aws:iam::696148199696:role/ecsTaskExecutionRole" #手動作成
  container_definitions = jsonencode([
    {
      "name" : "web",
      "image" : "024835775511.dkr.ecr.ap-northeast-1.amazonaws.com/hashimoto-jcb-test-ecr:latest", #手動でECRにpushしたimage
      "memory" : 3072,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        },
        {
          "containerPort" : 443,
          "hostPort" : 443
        }
      ],
      "environment" : [
        {
          "name" : "APP_ENV",
          "value" : "ecs_test"
        }
      ]
    },
  ])
  lifecycle {
    #ignore_changes = all
  }
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name                               = "hashimoto-jcb-test-ecs-service"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = "1800"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_execute_command             = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:024835775511:targetgroup/hashimoto-jcb-test-tg-1/e4c984ed1be249d9"
    container_name   = "web"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      task_definition,
      network_configuration
    ] #MySQL57対応
  }

  network_configuration {
    subnets = [
      "subnet-bc4d00f5",
      "subnet-0fe55c54"
    ]

    security_groups = [
      "sg-000e5d541e1d60213" #手動で作成したSG
    ]

    assign_public_ip = "true"
  }
}

#ECS Log
#resource "aws_cloudwatch_log_group" "logs" {
#  name              = "/fargate/service/${var.common["project"]}-${var.env}-ecs"
#  retention_in_days = "365"
#}
*/