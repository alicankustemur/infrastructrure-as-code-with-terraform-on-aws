provider "aws" {
    region = "${var.region}" 
}

// VPC

data "aws_vpc" "default" {
  default = true
}

// Public Subnet
resource "aws_subnet" "public" {
    vpc_id = "${data.aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_block}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "public"
    }
}

# //  Security Group
resource "aws_security_group" "public" {
    name = "public"
    description = "Allow traffic to pass from the public subnet to the internet"
    vpc_id = "${data.aws_vpc.default.id}"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.everywhere_cidr_block}"]
    }

    # for SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.everywhere_cidr_block}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.everywhere_cidr_block}"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.everywhere_cidr_block}"]
    }

    tags {
        Name = "public"
    }
}

// Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = "${file("${var.public_key_path}")}"
}

// Get Ubuntu AMI id from Marketplace
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

// Instance
resource "aws_instance" "web" {
    ami = "${data.aws_ami.ubuntu.id}"  # Ubuntu 16.04 LTS https://cloud-images.ubuntu.com/locator/ec2/
    availability_zone = "${var.availability_zone}"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.my_key.key_name}"
    vpc_security_group_ids = ["${aws_security_group.public.id}"]
    subnet_id = "${aws_subnet.public.id}"
    associate_public_ip_address = true

    tags {
         Name = "${terraform.workspace}_instance"
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