// Get Ubuntu AMI from Marketplace
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}