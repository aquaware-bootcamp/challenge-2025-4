module "network" {
    source   = "./network"
}

module "compute" {
    source   = "./compute"
    subnet_id              = module.network.private_subnet_ids[0]
    security_group_ids     = [module.security.web_sg_id]
    iam_instance_profile   = module.security.ec2_instance_profile_name
    aws_region             = var.region
}

module "rds_postgresql" {
    source   = "./database/RDS/postgresql"
    vpc_id   = module.network.vpc_id
    private_subnet_ids = module.network.private_subnet_ids
    db_security_group_ids = [module.security.db_sg_id]
    db_subnet_group_name_id = "pg-subnets-private"
}

module "security" {
    source   = "./security"
    vpc_id   = module.network.vpc_id
    private_subnet_ids = module.network.private_subnet_ids
    app_security_group_id = module.security.web_sg_id
    db_password_secret_arn = module.rds_postgresql.db_secret_arn
}

module "endpoints" {
    source   = "./endpoints"
    vpc_id   = module.network.vpc_id  
    aws_region = var.region
    subnet_id = module.network.private_subnet_ids 
    sg_id = module.security.endpoint_sg_id
}
