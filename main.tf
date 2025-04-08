provider "aws" {
  region = "us-west-2"
}

data "aws_iam_role" "existing_role" {
  name = "example-role-new"
}

resource "aws_iam_role" "example" {
  count = length(data.aws_iam_role.existing_role.arn) == 0 ? 1 : 0
  name = "example-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_eks_cluster" "example" {
  name     = "example-cluster"
  role_arn = length(data.aws_iam_role.existing_role.arn) == 0 ? aws_iam_role.example.arn : data.aws_iam_role.existing_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.example[0].id, aws_subnet.example[1].id]
  }
}

resource "aws_subnet" "example" {
  count = 2
  vpc_id = aws_vpc.example.id
  cidr_block = cidrsubnet(aws_vpc.example.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {}
