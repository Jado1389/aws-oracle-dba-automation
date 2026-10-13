resource "aws_route_table" "public" {
  vpc_id = aws_vpc.oracle.id

  tags = {
    Name        = "oracle-public-rt"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
    Tier        = "public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.oracle.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.oracle.id

  tags = {
    Name        = "oracle-private-rt"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
    Tier        = "private"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
