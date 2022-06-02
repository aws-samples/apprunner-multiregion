variable "registry_scanning" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}

data "aws_caller_identity" "current" {}
data "aws_regions" "current" {}

# cross-region replication
resource "aws_ecr_replication_configuration" "main" {
  replication_configuration {
    rule {
      destination {
        region      = var.region_alternate
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

# create an ECR repo at the app/image level
resource "aws_ecr_repository" "main" {
  name                 = var.app
  image_tag_mutability = "IMMUTABLE"
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = var.registry_scanning
  }
}

resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:StartLifecyclePolicyPreview",
    ]

    principals {
      type = "AWS"

      identifiers = [
        data.aws_caller_identity.current.id,
      ]
    }
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.main.repository_url
}

output "ecr_repo_url_replicated" {
  value = replace(aws_ecr_repository.main.repository_url, var.region, var.region_alternate)
}

