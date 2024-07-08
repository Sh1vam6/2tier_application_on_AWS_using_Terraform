# creating vpc in a region
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# creating an internet gateway for public access
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-IG"
  }
}

# use data sources to get all az's in a region

data "aws_availability_zones" "azs" {}


# creating public subnet in az1

resource "aws_subnet" "public-subnet-az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-az1"
  }
}

# creating public subnet in az2

resource "aws_subnet" "public-subnet-az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-az2"
  }
}

# creating public route table and associating with public subnet 

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "${var.project_name}-public-RT"
  }
}

# associate public-subnet-az1 with publicRT 

resource "aws_route_table_association" "public-subnet-az1-route-associate" {
  subnet_id      = aws_subnet.public-subnet-az1.id
  route_table_id = aws_route_table.publicRT.id
}


# associate public-subnet-az2 with publicRT 

resource "aws_route_table_association" "public-subnet-az2-route-associate" {
  subnet_id      = aws_subnet.public-subnet-az2.id
  route_table_id = aws_route_table.publicRT.id
}

# creating private-data-subnet in az1

resource "aws_subnet" "private-data-subnet-az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-data-az1"
  }
}


# creating private-data-subnet in az2

resource "aws_subnet" "private-data-subnet-az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-data-az2"
  }
}




