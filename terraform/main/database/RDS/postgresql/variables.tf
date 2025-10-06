variable "vpc_id" {
    description = "The VPC ID where the RDS instance will be deployed."
    type        = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs for the RDS subnet group."
    type        = list(string)
}

variable "db_security_group_ids" {
    description = "List of security group IDs to attach to the RDS instance."
    type        = list(string)
}

variable "db_subnet_group_name_id" {
    description = "The name of the DB subnet group for the RDS instance."
    type        = string    
}