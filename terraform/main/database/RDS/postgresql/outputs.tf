output "db_endpoint" {
    description = "The DNS endpoint address of the PostgreSQL RDS instance."
    value       = aws_db_instance.postgres.address
}

    output "db_password" {
    description = "The generated password for the PostgreSQL instance."
    value       = random_password.db_password.result
    sensitive   = true # Marca como sensible
}

output "db_secret_arn" {
    description = "The ARN of the Secrets Manager entry for the master user password."
    value       = aws_db_instance.postgres.master_user_secret[0].secret_arn 
}