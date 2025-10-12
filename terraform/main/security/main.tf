# SG para la instancia (web-sg) - Permite la salida abierta para el SSM Agent
resource "aws_security_group" "web" {
    name        = "web-sg"
    description = "Optional HTTP access"
    vpc_id      = var.vpc_id

    # ingress {
    #     from_port   = 22
    #     to_port     = 22
    #     protocol    = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    #     }

    # Salida abierta: ABSOLUTAMENTE NECESARIO para que el SSM Agent inicie la conexión HTTPS
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Marco-ch-sg-web"
    }
}

# En tu módulo de Seguridad o IAM (donde está definido el Rol de EC2)
# ESTE ES EL BLOQUE CORRECTO PARA AGREGAR EL PERMISO DE SECRETS MANAGER
resource "aws_iam_role_policy" "rds_secret_reader" {
    name = "rds-secret-reader-policy"
    
    # ⭐ Referencia al ID de tu Rol de Instancia EC2
    # Asegúrate de que 'aws_iam_role.ec2_role' es el nombre correcto de tu recurso Role.
    role = aws_iam_role.ec2_role.id 

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            
            # ⭐ RECURSO (ARN) RESTRICTIVO: Solo permite leer el secreto que RDS creó.
            # Usamos 'master_user_secret[0].secret_arn' que RDS popula automáticamente.
            Resource = var.db_password_secret_arn
        }
        ]
    })
}

# SG para los endpoints de SSM
resource "aws_security_group" "ssm_endpoint" {
    name        = "marco-ch-sg-ssm-endpoint"
    description = "SG for SSM VPC Endpoints"
    vpc_id      = var.vpc_id

    # Salida abierta (Recomendado)
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Marco-ch-sg-ssm-endpoint"
    }
}

# 2. Security Group de la Base de Datos (Solo permite tráfico del EC2)
resource "aws_security_group" "db" {
    name        = "db-sg-postgres"
    description = "Allow port 5432 from App EC2 Security Group"
    vpc_id      = var.vpc_id

    # Regla INGRESS: Solo permite tráfico en 5432/tcp desde el SG de la aplicación (EC2)
    ingress {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        # Referencia al SG de la capa de aplicación (web-sg)
        security_groups = [var.app_security_group_id]
    }

    # Regla EGRESS: Salida abierta para cualquier actualización o comunicación de AWS
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "marco-rds-sg"
    }
}

# 1. Grupo de Subredes para RDS (Necesario para alta disponibilidad)
resource "aws_db_subnet_group" "postgres" {
    name       = "pg-subnets-private"
    # Usa las IDs de las subredes privadas que vienen del módulo 'network'
    subnet_ids = var.private_subnet_ids
    tags = {
        Name = "marco-rds-subnets"
    }
}

#  REGLA CRUCIAL: Conexión Inbound al Endpoint desde el SG de la instancia (TCP 443)
resource "aws_security_group_rule" "ssm_endpoint_inbound_from_ec2" {
    # El destino de esta regla es el SG del endpoint
    security_group_id = aws_security_group.ssm_endpoint.id 

    # Tráfico de Entrada
    type              = "ingress" 

    # Puerto de comunicación de SSM
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"

    # El origen del tráfico es el SG de la instancia (aws_security_group.web)
    source_security_group_id = aws_security_group.web.id
}

# 1. IAM Role para SSM (Entidad de Confianza para EC2 y SSM Automation)
resource "aws_iam_role" "ec2_role" {
    name = "marco-ec2-ssm-role_v1"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        },
        # Añadir ssm.amazonaws.com para que el servicio pueda asumir el rol (Automation)
        {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
            Service = "ssm.amazonaws.com"
            }
        }
        ]
    })
}

# 5. Adjuntar la política de lectura de IAM personalizada (Para que el Runbook pueda verificar los perfiles)
resource "aws_iam_role_policy" "ssm_automation_iam_read" {
    name = "SSM-Automation-IAM-Read"
    role = aws_iam_role.ec2_role.id

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "iam:GetInstanceProfile",
                    "iam:GetRole"
                ],
                "Resource": "*"
            }
        ]
    })
}

# CORRECCIÓN DE IAM: Adjuntar la política administrada (reemplaza la política en línea manual)

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
    role  = aws_iam_role.ec2_role.name
    # Esta política contiene TODOS los permisos necesarios para que el agente SSM se registre.
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_role_policy_attachment" "ssm_automation_attachment" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole" 
}

# 4. Adjuntar la política de solo lectura de EC2 (Para que el Runbook pueda inspeccionar la instancia)
resource "aws_iam_role_policy_attachment" "ec2_read_only_attachment" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" 
}

# Instance Profile (Utiliza el rol)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "marco-ec2-ssm-instance-profile"
    role = aws_iam_role.ec2_role.name
}


data "aws_caller_identity" "current" {}
#rol para git actioons
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    sid     = "AllowGitHubActionsToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # El ARN del proveedor OIDC de GitHub (usando tu Account ID)
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    # Condición de Autenticación OIDC estándar
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    
    # Restricción: Solo permite la asunción si el repositorio y la rama son correctos
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        # Permiso para la rama 'main'
        "repo:aquaware-bootcamp/challenge-2025-4:ref:refs/heads/main",
        # Permiso para tu rama 'marco'
        "repo:aquaware-bootcamp/challenge-2025-4:ref:refs/heads/marco"
      ]
    }
  }
}

# 3. Creación del Rol de IAM
resource "aws_iam_role" "github_validation_role" {
  name               = "github-validation-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
  # Opcional: añade tags para organización
  tags = {
    Project = "Bootcamp-Day6-SSM"
  }
}
    #politicas


# Política de Permisos: Permite ejecutar comandos de SSM y obtener el estado
resource "aws_iam_role_policy" "github_ssm_permissions" {
  name = "ssm-validation-access"
  role = aws_iam_role.github_validation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ec2:DescribeInstances" 
        ],
        # Restringimos el Resource de SSM a tu región para mayor seguridad (opcional)
        Resource = "*"       }
    ]
  })
}


# ROL PARA LAMBDA OIDC PROVISIONER

# --- Reutiliza el proveedor OIDC y datos existentes ---

# --- Política de confianza para Terraform Workflow ---
data "aws_iam_policy_document" "github_oidc_trust_terraform" {
  statement {
    sid     = "AllowGitHubActionsToAssumeTerraformRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    # Condiciones estándar OIDC
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Solo permite acceso desde tu repo y ramas específicas
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:aquaware-bootcamp/challenge-2025-4:ref:refs/heads/main",
        "repo:aquaware-bootcamp/challenge-2025-4:ref:refs/heads/marco"
      ]
    }
  }
}

# --- Rol de Terraform ---
resource "aws_iam_role" "github_terraform_role" {
  name               = "marco-github-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust_terraform.json

  tags = {
    Project = "Bootcamp-Day7-Terraform"
  }
}

# --- Política con permisos de Terraform ---
data "aws_iam_policy_document" "terraform_permissions" {
  statement {
    sid    = "TerraformInfrastructureAccess"
    effect = "Allow"
    actions = [
      "ec2:*",
      "vpc:*",
      "iam:*",
      "s3:*",
      "cloudwatch:*",
      "ssm:*",
      "rds:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_policy" {
  name        = "terraform-full-access"
  description = "Permite a Terraform administrar recursos básicos"
  policy      = data.aws_iam_policy_document.terraform_permissions.json
}

# --- Asociar la política al rol ---
resource "aws_iam_role_policy_attachment" "terraform_role_attachment" {
  role       = aws_iam_role.github_terraform_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

  #segunda politica para rol de tf con git (para leer el backend s3)
  resource "aws_iam_policy" "terraform_backend_access" {
  name        = "TerraformBackendAccess"
  description = "Permite acceso a S3 y DynamoDB para Terraform backend"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::tfstate-marco-ai-bootcamp-2",
          "arn:aws:s3:::tfstate-marco-ai-bootcamp-2/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:711387135481:table/tflock-marco-ai-bootcamp-2"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_policy" {
  role       = aws_iam_role.github_terraform_role.name
  policy_arn = aws_iam_policy.terraform_backend_access.arn
}

