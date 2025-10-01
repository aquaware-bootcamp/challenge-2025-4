variable "region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for remote state"
  default     = "tfstate-marco-ai-bootcamp-2"
}

variable "lock_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
  default     = "tflock-marco-ai-bootcamp-2"
}
