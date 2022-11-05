terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "vpcnuveidemobucket"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
    #State locking configuration
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

