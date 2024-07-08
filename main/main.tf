# creating vpc (referencing the module)

module "vpc" {
  source       = "../modules/vpc"
  region       = var.region
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr

}

module "sg" {
  source = "../modules/sg"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

module "nat-gateway" {
  source                     = "../modules/nat-gateway"
  vpc_id                     = module.vpc.vpc_id
  internet_gateway           = module.vpc.internet_gateway
  public-subnet-az1-id       = module.vpc.public-subnet-az1-id
  public-subnet-az2-id       = module.vpc.public-subnet-az2-id
  private-data-subnet-az1-id = module.vpc.private-data-subnet-az1-id
  private-data-subnet-az2-id = module.vpc.private-data-subnet-az2-id
}

module "auto-sg" {
  source                                        = "../modules/auto-sg"
  project_name                                  = module.vpc.project_name
  min_size                                      = var.min_size
  max_size                                      = var.max_size
  desired_capacity                              = var.desired_capacity
  public-subnet-az1-id                          = module.vpc.public-subnet-az1-id
  private-data-subnet-az1-id                    = module.vpc.private-data-subnet-az1-id
  private-data-subnet-az2-id                    = module.vpc.private-data-subnet-az2-id
  public-subnet-az2-id                          = module.vpc.public-subnet-az2-id
  private_instance_sg_id                        = module.sg.private_instance_sg_id
  public_instance_sg_id                         = module.sg.public_instance_sg_id
  instance-type                                 = var.instance_type
  public_loadbalancer_target_group_arn          = module.lb.public_loadbalancer_target_group_arn
  private_loadbalancer_target_group_arn         = module.lb.private_loadbalancer_target_group_arn
  public_loadbalancer_arn                       = module.lb.public_loadbalancer_arn
  aws_lb_listener_alb_public_https_listener_arn = module.lb.aws_lb_listener_alb_public_https_listener_arn
  vpc_id                                        = module.vpc.vpc_id
  ami                                           = var.ami
}

module "lb" {
  source                                                        = "../modules/lb"
  vpc_id                                                        = module.vpc.vpc_id
  aws_acm_certificate_validation_acm_certificate_validation_arn = module.acm.aws_acm_certificate_validation_acm_certificate_validation_arn
  project_name                                                  = module.vpc.project_name
  public-subnet-az1-id                                          = module.vpc.public-subnet-az1-id
  public-subnet-az2-id                                          = module.vpc.public-subnet-az2-id
  private-data-subnet-az1-id                                    = module.vpc.private-data-subnet-az1-id
  private-data-subnet-az2-id                                    = module.vpc.private-data-subnet-az2-id
  private_instance_sg_id                                        = module.sg.private_instance_sg_id
  public_instance_sg_id                                         = module.sg.public_instance_sg_id
  public_loadbalancer_target_group_arn                          = module.lb.public_loadbalancer_target_group_arn
}

module "acm" {
  source           = "../modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name

}

module "route-53" {
  source                     = "../modules/route53"
  aws_lb_public_alb_dns_name = module.lb.aws_lb_public_alb_dns_name
  aws_lb_public_alb_zone_id  = module.lb.aws_lb_public_alb_zone_id

}


