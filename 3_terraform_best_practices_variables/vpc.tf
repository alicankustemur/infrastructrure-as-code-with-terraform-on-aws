// Virtual Private Cloud (VPC)
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform_aws_vpc"
    }
}