# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for web server setup
locals {
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Create a simple HTML page
    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
        <title>${var.project_name} - ${var.environment}</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f0f0; }
            .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { color: #333; }
            .info { background-color: #e7f3ff; padding: 15px; border-radius: 4px; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Terraform GitOps Demo</h1>
            <div class="info">
                <h3>Infrastructure Details:</h3>
                <p><strong>Project:</strong> ${var.project_name}</p>
                <p><strong>Environment:</strong> ${var.environment}</p>
                <p><strong>Instance Type:</strong> ${var.instance_type}</p>
                <p><strong>Deployed via:</strong> Terraform + GitHub Actions</p>
            </div>
            <p>This web server was automatically deployed using Terraform modules and triggered by a Git push!</p>
            <p><em>Server Time: $(date)</em></p>
        </div>
    </body>
    </html>
HTML
    
    # Set proper permissions
    chown -R apache:apache /var/www/html/
    chmod -R 644 /var/www/html/
    EOF
  )
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : null
  
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  
  user_data = local.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-web-server"
    Type = "WebServer"
  })
}

# Elastic IP for the web server (optional)
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-web-eip"
  })

  depends_on = [aws_instance.web]
}
