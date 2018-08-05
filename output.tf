
output "private_key_path_for_ssh" {
  value = "${var.private_key_path}"
}

output "public_ip_for_ssh" {
  value = "${aws_instance.terraform_instance.public_ip}"
}
output "username_for_ssh" {
  value = "${var.ssh_username}"
}
