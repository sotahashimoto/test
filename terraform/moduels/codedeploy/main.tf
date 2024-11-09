resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "test-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "group" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "test-codedeploy-group"
  service_role_arn       = "arn:aws:iam::696148199696:role/ECSodeDeployRole" #手動作成

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 30
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  #ecs_service {
  #  cluster_name = "hashimoto-jcb-test-cluster" #本番時は直書きしない
  #  service_name = "hashimoto-jcb-test-ecs-service" #本番時は直書きしない
  #}

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          "arn:aws:elasticloadbalancing:ap-northeast-1:696148199696:listener/app/test-alb/a11fc41772fe5a52/52d8988602d1ee8f"
        ]
      }

      target_group {
        name = "test-tg"
      }
    }
  }
}