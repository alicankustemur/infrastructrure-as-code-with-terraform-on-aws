// Public Route Table
resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.default.id}"
    
    route {
        cidr_block = "${var.everywhere_cidr_block}"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
    
    tags {
        Name = "public"
    }
}