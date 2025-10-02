resource "aws_security_group" "web" {
    name        = "web-sg"
    description = "Optional HTTP access"
    vpc_id      = var.vpc_id   # viene del módulo network (pasado desde el root)

    # Entrada opcional HTTP
    # ingress {
    #     from_port   = 80
    #     to_port     = 80
    #     protocol    = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    # Salida abierta
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

# IAM Role para SSM
resource "aws_iam_role" "ec2_role" {
    name = "marco-ec2-ssm-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        }
        ]
    })
}

# Inline policy mínima para SSM
resource "aws_iam_role_policy" "ec2_ssm_policy" {
    name = "marco-ec2-ssm-minimal"
    role = aws_iam_role.ec2_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        # Permisos existentes
        { Effect = "Allow", Action = ["ssm:UpdateInstanceInformation"], Resource = "*" },
        { Effect = "Allow", Action = ["ssmmessages:*"], Resource = "*" },
        { Effect = "Allow", Action = ["ec2messages:*"], Resource = "*" },

        # Permisos adicionales necesarios para Session Manager
        { Effect = "Allow", Action = [
            "ssm:DescribeInstanceInformation",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:DescribeDocument",
            "ssm:SendCommand",
            "ssm:ListCommandInvocations",
            "ssm:ListCommands"
            ], Resource = "*" },
        { Effect = "Allow", Action = [
            "cloudwatch:PutMetricData"
            ], Resource = "*" },
        { Effect = "Allow", Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
            ], Resource = "*" }
        ]
    })
}


# Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "marco-ec2-ssm-instance-profile"
    role = aws_iam_role.ec2_role.name
}