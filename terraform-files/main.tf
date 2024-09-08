provider "aws" {
  region = "us-west-2"  # Specify the AWS region
}

# Security Group allowing SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = ["vpc-0d4f69f9efe538ba8"]
}
  ingress {
    description  = "SSH"
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]  # Open to the world; replace with specific IP if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "allow_ssh_security_group"
  }
}

# EC2 Instance
resource "aws_instance" "test_server" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "keypair2"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]  # Reference to the created security group

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./keypair2.pem")
    host        = self.public_ip
  }

  # Remote exec provisioner to run a command on the instance after creation
  provisioner "remote-exec" {
    inline = ["echo 'wait to start the instance'"]
  }

  # Local exec provisioner to save the public IP of the instance to an inventory file
  provisioner "local-exec" {
    command = "echo ${aws_instance.test_server.public_ip} > inventory"
  }

  # Local exec provisioner to run an Ansible playbook
  provisioner "local-exec" {
    command = "ansible-playbook /var/lib/jenkins/workspace/Banking-finance/terraform-files/ansibleplaybook.yml"
  }

  tags = {
    Name = "test-server"
  }
}
