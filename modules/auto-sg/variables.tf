variable "project_name" {}
variable "instance-type"{}
variable "public_instance_sg_id" {}
variable "private_instance_sg_id" {}
variable "desired_capacity"{}
variable "min_size"{}
variable "max_size"{}
variable "public-subnet-az1-id"{}
variable "public-subnet-az2-id"{}
variable "private-data-subnet-az1-id"{}
variable "private-data-subnet-az2-id"{}
variable "public_loadbalancer_target_group_arn"{}
variable "private_loadbalancer_target_group_arn"{}
variable "public_loadbalancer_arn"{}
variable "vpc_id"{}
variable "aws_lb_listener_alb_public_https_listener_arn"{}
variable "ami"{}
