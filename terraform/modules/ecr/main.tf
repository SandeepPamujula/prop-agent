resource "aws_ecr_repository" "services" {
  count                = length(var.repository_names)
  name                 = "prop-agent-${var.environment}-${var.repository_names[count.index]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "prop-agent-${var.environment}-${var.repository_names[count.index]}"
      Environment = var.environment
    }
  )
}

resource "aws_ecr_lifecycle_policy" "services" {
  count      = length(aws_ecr_repository.services)
  repository = aws_ecr_repository.services[count.index].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
