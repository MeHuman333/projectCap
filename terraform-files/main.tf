resource "aws_instance" "test-server" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "keypair2"
  vpc_security_group_ids = ["sg-07fd8b117d47d4a3c"]  # Updated security group ID
  

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
