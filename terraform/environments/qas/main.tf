module "alb" {
  source = "../../moduels/alb"
}

module "ecr" {
  source = "../../moduels/ecr"
}

module "ecs" {
  source = "../../moduels/ecs"
}