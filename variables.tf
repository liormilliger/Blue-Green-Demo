variable "aws_region" {
  description = "The AWS region of deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_ami" {
  description = "The AMI for Ubuntu 24.04 LTS"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "instance_type" {
  description = "EC2 instance Type"
  type        = string
  default     = "t2.nano"
}
