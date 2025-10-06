variable "azs" {
    description = "List of availability zones"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    # default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}