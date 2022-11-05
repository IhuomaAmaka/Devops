#create S3 bucket
provider "aws" {
  region = var.region
}
resource "aws_kms_key" "myvpckey" {
  description             = "This key will encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "nuveibucket" {
  bucket = "vpcnuveidemobucket"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.myvpckey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

#Create Dynamodb table for state locking

resource "aws_dynamodb_table" "terraform-lock" {
  name             = "terraform-lock"
  hash_key         = "TestTableHashKey"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "TestTableHashKey"
    type = "S"
  }
}
