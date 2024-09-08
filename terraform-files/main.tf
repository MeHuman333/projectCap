resource "aws_instance" "test-server" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "keypair2"
  vpc_security_group_ids = ["sg-0b2cdab010111968c"]  # Updated security group ID
  subnet_id     = subnet-045f7591518975b08


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
