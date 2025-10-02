
# Configuración del backend de Terraform para almacenar el estado en S3 y 
#usar DynamoDB para el bloqueo
terraform {
    backend "s3" {
        bucket         = "tfstate-marco-ai-bootcamp-2"
        key            = "envs/dev/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "tflock-marco-ai-bootcamp-2"
        encrypt        = true
    }
}
