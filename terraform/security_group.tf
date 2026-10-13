resource "aws_security_group" "oracle" {
  name        = "oracle-dba-sg"
  description = "Security group for Oracle DBA lab"
  vpc_id      = aws_vpc.oracle.id

  tags = {
    Name        = "oracle-dba-sg"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
  }
}

resource "aws_vpc_security_group_egress_rule" "oracle_all_outbound" {
  security_group_id = aws_security_group.oracle.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow outbound traffic"
}
