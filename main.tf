#--------------------Provider Info------------------------------------
provider "aws" {
  region                   = "ap-south-1"
}
#-------------------PasswordlessSSH----------------------------------------------
resource "null_resource" "key" {
  provisioner "local-exec" {
    on_failure  = fail
    command = "sudo cp /var/tmp/Jenkins-Server.pem /home/ubuntu/.ssh/Jenkins-Server.pem"
  }
}
resource "null_resource" "key-ownership" {
  depends_on = [null_resource.key]
  provisioner "local-exec" {
    on_failure  = fail
    command = "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/Jenkins-Server.pem"
  }
}
resource "null_resource" "Transfer_ssh1" {
  depends_on = [null_resource.key]
  provisioner "local-exec" {
    on_failure = fail
    command = "sudo echo 'Host *\n\tStrictHostKeyChecking no\n\tUser ubuntu\n\tIdentityFile /home/ubuntu/.ssh/Jenkins-Server.pem' > config"
  }
}
resource "null_resource" "Transfer_ssh2" {
  depends_on = [null_resource.Transfer_ssh1]
  provisioner "local-exec" {
    on_failure = fail
    command = "sudo cp config /home/ubuntu/.ssh/config"
  }
}
