provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "my_repo" {
  name = "my-app"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ci-cd-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family = "my-task"
  container_definitions = jsonencode([
    {
      name      = "my-app",
      image     = "${aws_ecr_repository.my_repo.repository_url}:latest",
      memory    = 512,
      cpu       = 256,
      essential = true,
    }
  ])
}

resource "aws_ecs_service" "my_service" {
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  name            = "my_service"
}
