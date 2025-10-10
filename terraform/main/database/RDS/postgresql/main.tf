# Genera una contraseña aleatoria y segura para RDS
resource "random_password" "db_password" {
    length  = 20
    special = false
    # La guardamos en el state, no en Secrets Manager (por simplicidad de laboratorio)
}


# 3. Instancia RDS PostgreSQL
resource "aws_db_instance" "postgres" {
    identifier               = "marco-ch-rds-postgres"
    engine                   = "postgres"
    engine_version           = "15.12"
    instance_class           = "db.t3.micro"
    allocated_storage        = 20
    username                 = "pgadmin"
    parameter_group_name = aws_db_parameter_group.postgres_custom.name  
    # password                 = random_password.db_password.result # Contraseña generada
    manage_master_user_password = true
    db_subnet_group_name     = var.db_subnet_group_name_id
    vpc_security_group_ids   = var.db_security_group_ids
    skip_final_snapshot      = true
    publicly_accessible      = false # ⭐ Vital: Mantener en la red privada
    storage_encrypted        = true
    backup_retention_period  = 1
    
    # Si deseas usar Multi-AZ para alta disponibilidad:
    multi_az                 = false
}

resource "aws_db_parameter_group" "postgres_custom" {
    name   = "postgres-custom-pg-hba"
    family = "postgres15" # Usa la versión principal de tu motor
    
    # PARÁMETRO 1: Forzar SSL/TLS (Esto resuelve el fallo de pg_hba.conf)
    parameter {
        name  = "rds.force_ssl"
        value = "1" # '1' o 'on' obliga a usar SSL
    }
    
    # # PARÁMETRO 2: Habilitar el cifrado SSL en el servidor
    # parameter {
    #     name  = "ssl"
    #     value = "1" # '1' o 'on' habilita el soporte SSL
    # }
    
    # PARÁMETRO 3: Tu parámetro de prueba de logging
    parameter {
        name  = "log_connections" 
        value = "1" 
    }
    
    tags = {
        Name = "pg-hba-config"
    }
}