variable "aws_region" {
  description = "The AWS region for the deployment."
  type        = string
  default     = "us-east-1"
}

variable "blue-green-user-secret" {
  description = "The ARN of the AWS Secrets Manager secret holding the IAM credentials."
  type        = string
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

