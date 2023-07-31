#--------------------Provider Info------------------------------------
provider "aws" {
  region                   = "ap-south-1"
}
resource "aws_instance" "ansible-test" {
  ami           = "ami-08e5424edfe926b43"
  key_name      = "newkey"
  instance_type = "t2.micro"
  tags = {
    Name = "Ansible-master-1"
  }

 

  provisioner "remote-exec" {
    inline = [
      "echo 'hello' > test.txt",
    ]
    on_failure = fail

 

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/var/tmp/newkey.pem")
      host        = self.public_ip

 

    }
  }
}
