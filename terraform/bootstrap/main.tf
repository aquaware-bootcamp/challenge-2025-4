resource "aws_s3_bucket" "tf_state" {
    bucket = var.state_bucket_name

    tags = {
        Name        = "Terraform State Bucket - Marco"
        Environment = "Bootcamp"
    }
}

resource "aws_dynamodb_table" "tf_lock" {
    name         = var.lock_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Name        = "Terraform Lock Table - Marco"
        Environment = "Bootcamp"
    }
}
