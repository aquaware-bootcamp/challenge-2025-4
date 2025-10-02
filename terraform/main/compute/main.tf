locals {
    user_data = templatefile("${path.module}/../scripts/user_data.sh.tmpl", {
        region = var.aws_region
    })
}

resource "aws_instance" "dev" {
    ami                    = data.aws_ami.al2023.id
    instance_type          = var.instance_type
    subnet_id              = var.subnet_id
    vpc_security_group_ids = var.security_group_ids
    iam_instance_profile   = var.iam_instance_profile
    user_data              = local.user_data

    tags = {
        Name = "marco-ch-dev-instance"
    }
}

data "aws_ami" "al2023" {
    owners      = ["137112412989"] # Amazon official AMIs
    most_recent = true

    filter {
        name   = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}
