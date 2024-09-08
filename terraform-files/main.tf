resource "aws_instance" "test-server" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name      = "keypair2"
  vpc_security_group_ids = ["sg-061cb905e9260d542"]  # Updated security group ID
  subnet_id     = "subnet-07824c9539dd6baed"  # Ensure this subnet ID is in vpc-0d4f69f9efe538ba8

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./keypair2.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["echo 'wait to start the instance' "]
  }

  tags = {
    Name = "test-server"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.test-server.public_ip} > inventory"
  }

  provisioner "local-exec" {
    command = "ansible-playbook /var/lib/jenkins/workspace/Banking-finance/terraform-files/ansibleplaybook.yml"
  }
}
