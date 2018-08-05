provider "aws" {
  
}

// VPC

resource "aws_vpc" "default" {
    cidr_block = "${var.cidr_block}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform_aws_vpc"
    }
}

//  Security Group

resource "aws_security_group" "terraform_public_security_group" {
    name = "terraform_public_security_group"
    description = "Allow traffic to pass from the public subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.default.cidr_block}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "terraform_public_security_group"
    }
}

// Key Pair
resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "terraform_key_pair"
  public_key = "${file("${var.public_key_path}")}"
}

// Instance
resource "aws_instance" "terraform_instance" {
    ami = "ami-cd49ac20"  # Ubuntu 16.04 LTS https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#LaunchInstanceWizard:ami=ami-cd49ac20
    availability_zone = "${var.availability_zone}"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.terraform_key_pair.key_name}"
    vpc_security_group_ids = ["${aws_security_group.terraform_public_security_group.id}"]
    subnet_id = "${aws_subnet.terraform_public_subnet.id}"
    associate_public_ip_address = true

    connection {
        user                = "${var.ssh_username}"
        private_key         = "${file("${var.private_key_path}")}"
        agent               = false
        host                = "${aws_instance.terraform_instance.public_ip}"
    }

    tags {
        Name = "Istanbul Coders IaC Terraform"
    }

     provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y -qq && sudo apt-get install nginx -y -qq"
        ]
     }

}

// Public Subnet
resource "aws_subnet" "terraform_public_subnet" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "172.31.1.0/24"
    availability_zone = "eu-west-1a"

    tags {
        Name = "terraform_public_subnet"
    }
}

// Internet Gateway

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

// Public Route Table
resource "aws_route_table" "terraform_public_route_table" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "terraform_public_route_table"
    }
}

// Public Route Table Asscociation
resource "aws_route_table_association" "terraform_public_route_table_asccociation" {
    subnet_id = "${aws_subnet.terraform_public_subnet.id}"
    route_table_id = "${aws_route_table.terraform_public_route_table.id}"
}