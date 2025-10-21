terraform {
  backend "s3" {
    bucket = "liorm-portfolio-tfstate"
    key    = "blue-green-tfstate/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = var.blue-green-user-secret
}

locals {
  aws_credentials = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

provider "aws" {
  region     = var.aws_region
  access_key = local.aws_credentials.access_key
  secret_key = local.aws_credentials.secret_key
}

