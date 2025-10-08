variable "vpc_id" {
    description = "The ID of the VPC where the security group will be created"
    type        = string
}

variable "app_security_group_id" {
    description = "The security group ID for the application (e.g., EC2 instances) that will access the RDS instance."
    type        = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs for the RDS subnet group."
    type        = list(string)
}

variable "db_password_secret_arn" {
    description = "The ARN of the Secrets Manager secret that contains the RDS master user password."
    type        = string
}
