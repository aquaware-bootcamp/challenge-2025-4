variable "aws_region" {
    description = "AWS region where the instance will be deployed"
    type        = string
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t3.micro"
}

variable "subnet_id" {
    description = "Subnet ID for the EC2 instance"
    type        = string
}

variable "security_group_ids" {
    description = "List of security group IDs for the instance"
    type        = list(string)
}

variable "iam_instance_profile" {
    description = "IAM Instance Profile name for the EC2 instance"
    type        = string
}
