output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_eip.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.web.public_dns
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.web.private_ip
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.web.public_ip
}