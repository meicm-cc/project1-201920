provider "aws" {
  region = var.region
}

resource "aws_key_pair" "auth" {
  key_name   = "default"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "node_srv" {
  name = "node_srv"
  description = "Node Server Security Group"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "node" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "default"
  vpc_security_group_ids = [aws_security_group.node_srv.id]
}

output "public_ip" {
  value       = aws_instance.node.public_ip
}