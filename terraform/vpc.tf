resource "aws_vpc" "oracle" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "oracle-dba-vpc"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
  }
}
