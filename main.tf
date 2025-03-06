locals {
  files = fileset("./resume", "**/*")
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".jpg"  = "image/jpg"
  }

  files_debug = toset([for f in local.files : f])
}


data "aws_s3_bucket" "cloud_resume_challenge_laura_diaz" {
  bucket = var.bucket_name
}

variable "bucket_name" {
  description = "Name of the S3 bucket for the cloud resume challenge"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "aws_region" {
  description = "Domain name for the website"
  type        = string
}

variable "tf_state_bucket" {
  description = "S3 backend bucket name"
  type        = string
}

variable "tf_state_bucket_key" {
  description = "S3 backend bucket name"
  type        = string
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket  = var.tf_state_bucket
    key     = var.tf_state_bucket_key
    region  = var.aws_region
    encrypt = true
  }

}

provider "aws" {
  region = var.aws_region
}


resource "aws_s3_object" "objects" {
  for_each     = local.files
  bucket       = data.aws_s3_bucket.cloud_resume_challenge_laura_diaz.id
  key          = each.value
  source       = "./resume/${each.value}"
  etag         = filemd5("./resume/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
  depends_on   = [data.aws_s3_bucket.cloud_resume_challenge_laura_diaz]
}

