provider "aws" {
  region = "us-east-1a" # Change to your preferred region
}

variable "ec2_key_name" {
  description = "The name of the EC2 Key Pair"
  type        = string
}

# Create a Security Group for EC2
resource "aws_security_group" "app_sg" {
  name_prefix = "react_notes_app_sg"

  # Allow SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP Traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision EC2 Instance
resource "aws_instance" "react_notes_app" {
  ami           = "ami-04b4f1a9cf54c11d0" # Amazon ubuntu AMI
  instance_type = "t2.micro"
  key_name      = var.ec2_key_name
  security_groups = [
    aws_security_group.app_sg.name
  ]

  tags = {
    Name = "ReactNativeNotesApp"
  }

  # User Data to Bootstrap the Instance
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs git
    npm install pm2@latest -g
  EOF
}

# Output Public IP of EC2 Instance
output "ec2_public_ip" {
  value = aws_instance.react_notes_app.public_ip
}
