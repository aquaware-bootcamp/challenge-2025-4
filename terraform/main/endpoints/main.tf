resource "aws_vpc_endpoint" "ssm" {
    vpc_id             = var.vpc_id
    service_name       = "com.amazonaws.${var.aws_region}.ssm"
    vpc_endpoint_type  = "Interface"
    subnet_ids         = var.subnet_id
    security_group_ids = [var.sg_id]

    tags = {
        Name = "marco-ssm"
    }
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id             = var.vpc_id
    service_name       = "com.amazonaws.${var.aws_region}.ssmmessages"
    vpc_endpoint_type  = "Interface"
    subnet_ids         = var.subnet_id
    security_group_ids = [var.sg_id]

    tags = {
        Name = "marco-ssmmessages"
    }
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id             = var.vpc_id
    service_name       = "com.amazonaws.${var.aws_region}.ec2messages"
    vpc_endpoint_type  = "Interface"
    subnet_ids         = var.subnet_id
    security_group_ids = [var.sg_id]

    tags = {
        Name = "marco-ec2messages"
    }
}
