# creating security group for public instance

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instacne_sg"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh access"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

   ingress {
    description = "http access"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_instance_sg"
  }
}

# creating security group for private instance

resource "aws_security_group" "private_instance_sg" {
  name        = "private_instacne_sg"
  description = "enable http/https access on port 80/443 via public instance sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh access"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = [aws_security_group.public_instance_sg.id]
  }

   ingress {
    description = "http access"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  ingress {
    description = "https access"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_instance_sg"
  }
}