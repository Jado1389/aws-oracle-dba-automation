variable "aws_region" {
  description = "AWS region for the Oracle DBA lab"
  type        = string
  default     = "ca-central-1"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-0bf6dbeae330f5823"
}

variable "instance_type" {
  description = "EC2 instance type for the DBA lab"
  type        = string
  default     = "t3.small"
}
