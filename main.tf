#--------------------Provider Info------------------------------------
provider "aws" {
  region                   = "ap-south-1"
}
#-------------------Test----------------------------------------------
resource "null_resource" "hell0" {
  provisioner "local-exec" {
    on_failure = fail
    command = "echo Hello World"
  }
}
