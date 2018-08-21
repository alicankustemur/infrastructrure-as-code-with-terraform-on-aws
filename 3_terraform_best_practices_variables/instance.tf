// Instance
resource "aws_instance" "web" {
    ami = "${data.aws_ami.ubuntu.id}"  
    availability_zone = "${var.availability_zone}"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.my_key.key_name}"
    vpc_security_group_ids = ["${aws_security_group.public.id}"]
    subnet_id = "${aws_subnet.public.id}"
    associate_public_ip_address = true
    
    tags {
        Name = "web"
    }

    connection {
        user                = "${var.ssh_username}"
        private_key         = "${file("${var.private_key_path}")}"
        agent               = false
        host                = "${aws_instance.web.public_ip}"
    }
provisioner "remote-exec" {
    inline = [
            "sudo apt-get update -y -qq && sudo apt-get install nginx -y -qq"
        ]
    }
}