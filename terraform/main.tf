provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "my_repo" {
  name = "my-app"

  lifecycle {
    prevent_destroy = false  # Allow deletion of the repository, even if it contains images
  }
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

# Force delete images and the repository itself before destroying the repository
resource "null_resource" "delete_ecr_images" {
  depends_on = [aws_ecr_repository.my_repo]

  provisioner "local-exec" {
    command = <<EOT
      # Delete all images in the ECR repository
      IMAGE_DIGESTS=$(aws ecr list-images --repository-name my-app --query 'imageIds[*].imageDigest' --output text)
      
      if [ -n "$IMAGE_DIGESTS" ]; then
        for DIGEST in $IMAGE_DIGESTS; do
          echo "Deleting image with digest $DIGEST"
          aws ecr batch-delete-image --repository-name my-app --image-ids imageDigest=$DIGEST
        done
      fi

      # Now delete the repository
      echo "Deleting repository 'my-app'"
      aws ecr delete-repository --repository-name my-app --force
    EOT
  }

  # Ensure this runs only when destroying the infrastructure
  lifecycle {
    ignore_changes = [command]
  }
}
