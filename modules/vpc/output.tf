output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public-subnet-az1-id" {
  value = aws_subnet.public-subnet-az1.id
}

output "public-subnet-az2-id" {
  value = aws_subnet.public-subnet-az2.id
}

output "private-data-subnet-az1-id" {
  value = aws_subnet.private-data-subnet-az1.id
}

output "private-data-subnet-az2-id" {
  value = aws_subnet.private-data-subnet-az2.id
}

output "internet_gateway" {
  value = aws_internet_gateway.Igw
}

