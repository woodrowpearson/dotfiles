terraform {
  required_providers {
    aws = {
      version = "~> 5.6.2"
    }
  }
  backend "s3" {
    bucket  = "home-tfstate"
    key     = "home/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region              = "us-west-2"
  shared_config_files = ["../.aws-config"]
}

resource "aws_s3_bucket" "home-tfstate" {
  bucket = "home-tfstate"
}

resource "aws_s3_bucket_versioning" "home-tfstate" {
  bucket = aws_s3_bucket.home-tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "home-tfstate" {
  bucket = aws_s3_bucket.home-tfstate.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

