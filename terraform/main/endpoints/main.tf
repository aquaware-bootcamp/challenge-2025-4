resource "aws_vpc_endpoint" "ssm" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.ssm"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.subnet_id
    security_group_ids  = [var.sg_id]
    private_dns_enabled = true 

    tags = {
        Name = "marco-ssm"
    }
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.subnet_id
    security_group_ids  = [var.sg_id]
    private_dns_enabled = true

    tags = {
        Name = "marco-ssmmessages"
    }
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.subnet_id
    security_group_ids  = [var.sg_id]
    private_dns_enabled = true

    tags = {
        Name = "marco-ec2messages"
    }
}

resource "aws_vpc_endpoint" "ec2" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.ec2"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.subnet_id
    security_group_ids  = [var.sg_id]
    private_dns_enabled = true

    tags = {
        Name = "marco-ec2-control"
    }
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id       = var.vpc_id
    service_name = "com.amazonaws.${var.aws_region}.s3"
    # S3 usa el tipo Gateway, que solo requiere la tabla de ruteo
    vpc_endpoint_type = "Gateway"
    
    # Asocia a la tabla de ruteo de tu subred privada
    route_table_ids = ["rtb-00b2f6bdeaf6109f9"] 

    tags = {
        Name = "marco-s3-gateway"
    }
}

resource "aws_vpc_endpoint" "secretsmanager" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.subnet_id
    security_group_ids  = [var.sg_id]
    private_dns_enabled = true

    tags = {
        Name = "marco-secretsmanager"
    }
}
