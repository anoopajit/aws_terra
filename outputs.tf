output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "web_instance_public_ip" {
  description = "Public IP address of web server"
  value       = module.ec2.public_ip
}

output "web_instance_public_dns" {
  description = "Public DNS name of web server"
  value       = module.ec2.public_dns
}

output "s3_website_url" {
  description = "S3 website URL"
  value       = module.s3_website.website_url
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_website.bucket_name
}