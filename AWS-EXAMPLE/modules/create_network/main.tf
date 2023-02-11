# Define and create our VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = "${merge(map("Name", format("%s", var.vpc_name)),var.vpc_tags)}"
}

#Create PUBLICS SUBNETS IN THE VPC
resource "aws_subnet" "subnet_public_create" {
  count = "${length(var.cidr_blocks_public)}"
  vpc_id = aws_vpc.default.id
  cidr_block = "${element(var.cidr_blocks_public, count.index) }"
  availability_zone = "${element(var.az, count.index)}"
  tags = "${merge(map("Name", element(var.cidr_blocks_public, count.index)), var.vpc_tags)}"
  depends_on=[aws_vpc.default]
}

#Create PRIVATE SUBNETS IN THE VPC
resource "aws_subnet" "subnet_private_create" {
  count = "${length(var.cidr_blocks_private)}"
  vpc_id = aws_vpc.default.id
  cidr_block = "${element(var.cidr_blocks_private, count.index) }"
  availability_zone = "${element(var.az, count.index)}"
  tags = "${merge(map("Name", element(var.cidr_blocks_public, count.index)), var.vpc_tags)}"
  depends_on=[aws_vpc.default]
}

# DEFINE DE INTERNET GATEWAY ONLY IF  CREATE NEW VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
  tags = "${merge(map("Name", "Internet-Gateway"),var.vpc_tags)}"
  depends_on=[aws_vpc.default, aws_subnet.subnet_public_create]
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = "${merge(map("Name", "Public-route" ),var.vpc_tags)}"
  depends_on=[aws_internet_gateway.gw]
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  count = "${length(var.cidr_blocks_public)}"
  subnet_id = "${element(aws_subnet.subnet_public_create.*.id,count.index)}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
  depends_on=[aws_route_table.web-public-rt]
}

resource "aws_security_group" "nat" {
	name = "nat"
	description = "Allow services from the private subnet through NAT"
	vpc_id = "${aws_vpc.default.id}"

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = var.cidr_blocks_private
	}
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = var.cidr_blocks_private
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

  tags = "${merge(map("Name", "nat-SG" ),var.vpc_tags)}"
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.subnet_private_create.id
  tags = "${merge(map("Name", "nat_resource"),var.vpc_tags)}"
  depends_on=[aws_eip.nat_gateway]
}


resource "aws_route_table" "private_instances" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "to_private_instances" {
  subnet_id = aws_subnet.subnet_private_create.id
  route_table_id = aws_route_table.private_instances.id
}
