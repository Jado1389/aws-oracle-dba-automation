data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.oracle.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "oracle-public-subnet"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.oracle.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "oracle-private-subnet"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
    Tier        = "private"
  }
}
