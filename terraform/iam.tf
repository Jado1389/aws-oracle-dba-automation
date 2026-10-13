resource "aws_iam_role" "oracle_ec2_role" {
  name = "oracle-dba-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "oracle-dba-ec2-role"
    Project     = "aws-oracle-dba-automation"
    Environment = "lab"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.oracle_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "oracle_ec2_profile" {
  name = "oracle-dba-ec2-profile"
  role = aws_iam_role.oracle_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.oracle_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
