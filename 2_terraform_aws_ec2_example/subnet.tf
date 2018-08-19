// Public Subnet
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "172.31.1.0/24"
    availability_zone = "us-east-2a"
 
    tags{
            Name = "public"
    }
}