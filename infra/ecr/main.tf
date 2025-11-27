terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_region" "current" {}

resource "aws_ecr_repository" "lambda" {
  name = "matrix-inverse-lambda"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.lambda.repository_url
}

output "aws_region" {
  value = data.aws_region.current.name
}
