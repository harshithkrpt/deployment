provider "aws" {
  region = var.region
}

resource "aws_security_group" "spring_sg" {
  name        = "spring-boot-sg"
  description = "Allow SSH and HTTP 8080"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Spring Boot HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "spring_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  security_groups        = [aws_security_group.spring_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install java-openjdk11 -y

              mkdir /home/ec2-user/app
              cd /home/ec2-user/app

              cat <<EOT > app.jar
              $(base64 your-app.jar)
              EOT

              base64 -d app.jar > application.jar
              chmod +x application.jar

              nohup java -jar application.jar > app.log 2>&1 &
              EOF

  tags = {
    Name = "SpringBoot-Terraform"
  }
}