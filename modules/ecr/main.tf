# modules/ecr/main.tf

locals {
    # default repositories
    default_repositories = [
        "l-backend",
        "l-populate",
    ]

    repositories = local.default_repositories
}

resource "aws_ecr_repository" "ecr_repos" {
  for_each = toset(local.repositories)

  name = "${var.project_name}-${var.env}-${each.value}"

  image_tag_mutability = "MUTABLE" # Allows overwriting of tags like 'latest'

  image_scanning_configuration {
    scan_on_push = true
  }

}

# Lifecycle policy for each repository
resource "aws_ecr_lifecycle_policy" "ecr_repos" {
  for_each = toset(local.repositories)

  repository = aws_ecr_repository.ecr_repos[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the newest image tagged as 'dev'"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["dev"]
          countType      = "imageCountMoreThan"
          countNumber    = 1
        }
        action = {
          type = "expire"
        }
      },
    #   {
    #     rulePriority = 2
    #     description  = "Keep only the newest image tagged as 'qa'"
    #     selection = {
    #       tagStatus      = "tagged"
    #       tagPatternList = ["qa"]
    #       countType      = "imageCountMoreThan"
    #       countNumber    = 1
    #     }
    #     action = {
    #       type = "expire"
    #     }
    #   },
      {
        rulePriority = 4
        description  = "Keep only the newest image tagged as 'main'"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["main"]
          countType      = "imageCountMoreThan"
          countNumber    = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 5
        description  = "Keep newest 5 untagged or other tagged images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Add data source for current account ID
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Outputs
output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value = {
    for k in local.repositories : k => aws_ecr_repository.ecr_repos[k].repository_url
  }
}

output "repository_arns" {
  description = "ARNs of the created ECR repositories"
  value = {
    for k in local.repositories : k => aws_ecr_repository.ecr_repos[k].arn
  }
}
