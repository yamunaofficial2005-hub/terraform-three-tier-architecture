
module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  cidr_block   = var.cidr_block
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
}

module "ec2" {
  source = "./modules/ec2"

  project_name  = var.project_name
  instance_type = "t3.micro"

  private_subnet_ids = [
    module.networking.private_subnet_ids[0],
    module.networking.private_subnet_ids[1]
  ]

  app_security_group_id = module.networking.app_security_group_id
  target_group_arn      = module.alb.target_group_arn
}

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name

  private_db_subnet_ids = [
    module.networking.private_subnet_ids[2],
    module.networking.private_subnet_ids[3]
  ]

  db_security_group_id = module.networking.db_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}
