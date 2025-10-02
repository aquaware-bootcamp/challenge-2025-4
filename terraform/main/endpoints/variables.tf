variable "aws_region" {
    description = "AWS region where the endpoints will be created"
    type        = string
}

variable "vpc_id" {
    description = "The ID of the VPC where the endpoints will be created"
    type        = string
}

variable "subnet_id" {
    description = "List of private subnet IDs for the VPC endpoints"
    type        = list(string)  
}

variable "sg_id" {
    description = "Security Group ID for the VPC endpoints"
    type        = string
}