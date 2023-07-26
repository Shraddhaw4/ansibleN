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
