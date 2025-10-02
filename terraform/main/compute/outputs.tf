output "ec2_instance_id" {
    description = "ID of the EC2 instance"
    value       = aws_instance.dev.id
}

output "ec2_public_ip" {
    description = "Public IP of the EC2 instance"
    value       = aws_instance.dev.public_ip
}

output "ec2_private_ip" {
    description = "Private IP of the EC2 instance"
    value       = aws_instance.dev.private_ip
}
