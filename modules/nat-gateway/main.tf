# allocate elastic ip, this eip is used for nat-gateway-az1 in public subnet az1

resource "aws_eip" "eip-az1" {
  vpc = true

  tags = {
    Name = "eip-az1"
  }
}

# allocate elastic ip, this eip is used for nat-gateway-az2 in public subnet az2

resource "aws_eip" "eip-az2" {
  vpc = true

  tags = {
    Name = "eip-az2"
  }
}

# creating nat-gateway in public-subnet-az1

resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip-az1.id
  subnet_id     =  var.public-subnet-az1-id

  tags = {
    Name = "nat gateway az1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [var.internet_gateway]
}


# creating nat-gateway in public-subnet-az2

resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip-az2.id
  subnet_id     =  var.public-subnet-az2-id

  tags = {
    Name = "nat gateway az2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [var.internet_gateway]
}

# create private route table az1 for private-subnet-az1 add nat-gateway-az1

resource "aws_route_table" "private_route_table_az1" {
  vpc_id = var.vpc_id
  route {
    cidr_block =  "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "private-rt-az1"
  }
}

# associate private route-table-az1 with private-subnet-az1

resource "aws_route_table_association" "public-subnet-az1-route-associate" {
  subnet_id      = var.private-data-subnet-az1-id
  route_table_id = aws_route_table.private_route_table_az1.id
}

# create private route table az2 for private-subnet-az2 add nat-gateway-az2

resource "aws_route_table" "private_route_table_az2" {
  vpc_id = var.vpc_id
  route {
    cidr_block =  "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "private-rt-az2"
  }
}


# associate private route-table-az2 with private-subnet-az2

resource "aws_route_table_association" "public-subnet-az2-route-associate" {
  subnet_id      = var.private-data-subnet-az2-id
  route_table_id = aws_route_table.private_route_table_az2.id
}






