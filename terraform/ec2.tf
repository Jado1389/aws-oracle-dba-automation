resource "aws_instance" "oracle_dba" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.oracle.id]
  iam_instance_profile   = aws_iam_instance_profile.oracle_ec2_profile.name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"

    tags = {
      Name    = "oracle-dba-os"
      Project = "aws-oracle-dba-automation"
    }
  }

  tags = {
    Name        = "oracle-dba-server"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
    Role        = "Oracle-DBA"
  }
}
