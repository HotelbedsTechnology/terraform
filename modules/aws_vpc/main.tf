# This module build all basic infraestructure for AWS Environment (VPC, route Tables, IGW, NAT, Routes, Subnets, etc)

# Create VPC
resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "example vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"

  tags {
    Name = "example igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.mod.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mod.id}"
  }

  tags {
    Name = "example.public.routes"
  }
  
  depends_on = ["aws_internet_gateway.mod"]
}

# Create Public Subnets
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.mod.id}"
  cidr_block        = "${var.public_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.public_subnets)}"

  tags {
    Name = "$example.public.subnet.${element(var.azs, count.index)}"
  }

  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}

# Associate Public Subnets to the Public Route Table
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create a NAT Gateway for each Public Subnet
# Allocate an Elastic IP for each Nat Gateway
# A
resource "aws_eip" "nateip" {
  vpc   = true
  count = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"

  depends_on = ["aws_internet_gateway.mod"]
}

# Create Private Route Table
# Create an independent Route Table for each AZ
resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.mod.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  count            = "${length(var.azs)}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  }

  tags {
    Name = "example.private.routes.${element(var.azs, count.index)}"
  }
}

# Create Private Subnets
# Assign each subnet to a diferent AZ
# If there are more subnets than AZs defined this will fail
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.mod.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.private_subnets)}"

  tags {
    Name = "example.private.subnet.${element(var.azs, count.index)}"
  }
}

# Associate Private Subnets to the Private Route Table
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
