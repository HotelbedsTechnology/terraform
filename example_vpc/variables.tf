variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "aws_region" {
	default = "eu-west-1"
}
variable "aws_azs" {
	default = ["eu-west-1a", "eu-west-1b"]
}
variable "aws_images" {
	type = "map"
	default = {
		eu-west-1 = "ami-78c0620b"
	}
}

variable "aws_cidr" { }
variable "aws_public_subnets" {
	type = "list"
}
variable "aws_private_subnets" {
	type = "list"
}
