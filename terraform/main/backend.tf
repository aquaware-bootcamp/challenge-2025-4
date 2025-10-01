terraform {
    backend "s3" {
        bucket         = "tfstate-marco-ai-bootcamp-2"
        key            = "envs/dev/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "tflock-marco-ai-bootcamp-2"
        encrypt        = true
    }
}
