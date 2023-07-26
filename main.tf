#--------------------Provider Info------------------------------------
provider "aws" {
  region                   = "ap-south-1"
}
#-------------------PasswordlessSSH----------------------------------------------
resource "null_resource" "key" {
  provisioner "local-exec" {
    on_failure  = fail
    command = "sudo cp /var/tmp/Demo_ans_key.pem /home/ubuntu/.ssh/Demo_ans_key.pem"
  }
}
resource "null_resource" "Transfer_ssh1" {
  depends_on = [null_resource.key]
  provisioner "local-exec" {
    on_failure = fail
    command = "sudo echo 'Host *\n\tStrictHostKeyChecking no\n\tUser ubuntu\n\tIdentityFile /home/ubuntu/.ssh/Demo_ans_key.pem' > config"
  }
}
resource "null_resource" "Transfer_ssh2" {
  depends_on = [null_resource.Transfer_ssh1]
  provisioner "local-exec" {
    on_failure = fail
    command = "sudo cp config /home/ubuntu/.ssh/config"
  }
}
#---------------Creating Inventory-------------------------------
resource "null_resource" "inventory" {
  provisioner "local-exec" {
    on_failure  = fail
    command = "echo '[servers]' > inventory"
  }
}
#-----------------Fetching Ubuntu AMI------------------------------
data "aws_ami" "ubuntu-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
#-----------------Ansibe Host---------------------------------------
resource "aws_instance" "ansible-hosts" {
  ami = data.aws_ami.ubuntu-ami.id
  instance_type = "t2.micro"
  key_name = "Demo_ans_key"

  tags = {
    Name = "terr-ansible-host"
  }
}
#----------------Inventory File--------------------------------------
resource "null_resource" "inventory-file" {
  depends_on = [aws_instance.ansible-hosts,null_resource.inventory]
  provisioner "local-exec" {
    on_failure = fail
    command = "echo ${aws_instance.ansible-hosts.tags["Name"]} ansible_host=${aws_instance.ansible-hosts.public_ip} ansible_connection=ssh ansible_user=ubuntu >> inventory"
  }
}
resource "null_resource" "ping" {
  depends_on = [null_resource.inventory-file, aws_instance.ansible-hosts]
  provisioner "local-exec" {
    on_failure = fail
    command = "ansible servers -m ping -i inventory"
  }
}
