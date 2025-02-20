terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.87.0"
    }
  }
  backend "s3" {
      bucket         = "aws-s3-demo-terraform-backend"
      key            = "terraform/state.tfstate"
      region         = "us-east-1"
      encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

