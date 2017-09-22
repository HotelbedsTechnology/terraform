# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}


module "aws_vpc" {
	source = "../modules/aws_vpc"

	cidr 		= "${var.aws_cidr}"
	azs 		= "${var.aws_azs}"
	private_subnets = "${var.aws_private_subnets}"
	public_subnets 	= "${var.aws_public_subnets}"
	
	enable_nat_gateway = "true"
}
