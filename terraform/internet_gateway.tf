resource "aws_internet_gateway" "oracle" {
  vpc_id = aws_vpc.oracle.id

  tags = {
    Name        = "oracle-igw"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
  }
}
