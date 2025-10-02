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

module "security" {
    source   = "./security"
    vpc_id   = module.network.vpc_id
}

module "endpoints" {
    source   = "./endpoints"
    vpc_id   = module.network.vpc_id  
    aws_region = var.region
    subnet_id = module.network.private_subnet_ids 
    sg_id = module.security.endpoint_sg_id
}
