variable "azs" {
    description = "List of availability zones"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}