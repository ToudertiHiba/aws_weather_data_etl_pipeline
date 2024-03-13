variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "eu-west-3"
}

variable "ubuntu20_ami_id" {
  type        = string
  description = "Ubuntu 20.04 AMI ID"
  default     = "ami-0fd5a6e39cc90b0c2"
}

variable "ubuntu22_ami_id" {
  type        = string
  description = "Ubuntu 22.04 AMI ID"
  default = "ami-01b32e912c60acdfa"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}
