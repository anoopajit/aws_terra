terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Optional: Use S3 backend for state management
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "infrastructure/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones to use."
  type        = list(string)
}

variable "instance_type" {
  description = "The EC2 instance type to use."
  type        = string
}

variable "key_pair_name" {
  description = "The name of the AWS key pair to use for EC2 instances."
  type        = string
}
provider "aws" {
  region = var.region
}

# Local values
locals {
  project_name = "terraform-gitops-demo"
  environment  = var.environment
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name = local.project_name
  environment  = local.environment
  vpc_cidr     = var.vpc_cidr
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  
  tags = local.common_tags
}

# Security Group Module
module "security_groups" {
  source = "./modules/security"
  
  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  
  tags = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  project_name        = local.project_name
  environment         = local.environment
  instance_type       = var.instance_type
  key_pair_name       = var.key_pair_name
  
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.security_groups.web_security_group_id]
  
  tags = local.common_tags
}


# S3 Module for static website hosting
module "s3_website" {
  source = "./modules/s3"
  
  project_name = local.project_name
  environment  = local.environment
  
  tags = local.common_tags
}