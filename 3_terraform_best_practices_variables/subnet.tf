// Public Subnet
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr_block}"
    availability_zone = "${var.availability_zone}"
 
    tags{
            Name = "public"
    }
}