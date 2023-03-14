terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

locals {
  cluster_name      = "${terraform.workspace}_packer"
}

resource "aws_security_group" "rules" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.public_cidrblock]
  }

  dynamic "ingress" {
    for_each = var.service_ports
    iterator = service_port
    content {
      from_port = service_port.value.port
      to_port   = service_port.value.port
      protocol  = service_port.value.protocol
      description = service_port.value.description
      // This means, all ip address are allowed !
      // Not recommended for production.
      // Limit IP Addresses in a Production Environment !
      cidr_blocks = [var.public_cidrblock]
    }
  }

  tags = {
    Name = format("%s_%s", local.cluster_name, "security_rules")
  }
}

resource "tls_private_key" "aws_ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "private_key_pem" {
  private_key_pem = tls_private_key.aws_ec2.private_key_pem
}

resource "aws_key_pair" "key_pair" {
  public_key = tls_private_key.aws_ec2.public_key_openssh

  key_name = var.key_name
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.aws_ec2.private_key_pem}' > ./aws_ec2.pem
      chmod 0600 ./aws_ec2.pem
    EOT
  }
}

data "aws_subnet" "selected" {
  vpc_id            = var.vpc_id
  availability_zone = var.az
  cidr_block        = var.cidr_block
}

resource "aws_instance" "machine" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key_pair.id
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.rules.id]

  tags = {
    Name       = local.cluster_name
    Created_By = var.created_by
  }
}

resource "null_resource" "configure" {
  connection {
    user = "ubuntu"
    host = aws_instance.machine.public_ip
    private_key="${file("./aws_ec2.pem")}"
    agent = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo git clone https://github.com/richyen/dotfiles.git",
      "sudo ./dotfiles/bootstrap.sh --force"
    ]
  }
}

resource "local_file" "servers_yml" {
  filename        = "${abspath(path.root)}/servers.yml"
  file_permission = "0600"
  content         = <<-EOT
---
servers:
    type: ${var.instance_type}
    region: ${var.aws_region}
    az: ${var.az}
    public_ip: ${aws_instance.machine.public_ip}
    private_ip: ${aws_instance.machine.private_ip}
    public_dns: ${aws_instance.machine.public_dns}
EOT
}
