output "web_sg_id" {
    description = "ID of the web security group"
    value       = aws_security_group.web.id
}

output "ec2_instance_profile_name" {
    value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "endpoint_sg_id" {
    description = "ID of the endpoint security group"
    value       = aws_security_group.ssm_endpoint.id 
}

output "db_sg_id" {
    description = "ID of the RDS security group"
    value       = aws_security_group.db.id
}