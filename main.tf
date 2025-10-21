provider "aws" {
  region = var.aws_region
  # data "aws_secretsmanager_secret_version" "aws_creds" {
  #   secret_id = "your/secret/id"
  # }
}
