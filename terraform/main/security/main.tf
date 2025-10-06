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

# ⭐ REGLA CRUCIAL: Conexión Inbound al Endpoint desde el SG de la instancia (TCP 443)
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

# # 2. Adjuntar la política principal de administración (Para que la instancia se vuelva 'Managed: true')
# resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
#     role       = aws_iam_role.ec2_role.name
#     policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 
# }

# # 3. Adjuntar la política de permisos de automatización (Para ejecutar el Runbook)
# resource "aws_iam_role_policy_attachment" "ssm_automation_attachment" {
#     role       = aws_iam_role.ec2_role.name
#     policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole" 
# }

# # 4. Adjuntar la política de solo lectura de EC2 (Para que el Runbook pueda inspeccionar la instancia)
# resource "aws_iam_role_policy_attachment" "ec2_read_only_attachment" {
#     role       = aws_iam_role.ec2_role.name
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" 
# }

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

# ⭐ CORRECCIÓN DE IAM: Adjuntar la política administrada (reemplaza la política en línea manual)

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