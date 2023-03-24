resource "aws_vpc" "tf_vpc" {
    count = length(var.network_details.vpc_cidrs)
    cidr_block = var.network_details.vpc_cidrs[count.index]
    tags = {
      "Name" = var.network_details.vpc_tags[count.index]
    }  
}



resource "aws_subnet" "tf_subnet" {
    count = length(var.network_details.subnet_cidrs1)
    availability_zone = var.network_details.azs_subnet1[count.index]
    cidr_block = var.network_details.subnet_cidrs1[count.index]
    vpc_id = aws_vpc.tf_vpc[0].id
    tags = {
      "Name" = var.network_details.subnet_tags1[count.index]
    }  
}


resource "aws_subnet" "tf_subnet1" {
    count = length(var.network_details.subnet_cidrs2)
    availability_zone = var.network_details.azs_subnet2[count.index]
    cidr_block = var.network_details.subnet_cidrs2[count.index]
    vpc_id = aws_vpc.tf_vpc[1].id
    tags = {
      "Name" = var.network_details.subnet_tags2[count.index]
    }  
}


resource "aws_internet_gateway" "tf_igw" {
    vpc_id = aws_vpc.tf_vpc[0].id
    tags = {
      "Name" = var.network_details.igw_tags1
    }  
}

resource "aws_internet_gateway" "tf_igw1" {
    vpc_id = aws_vpc.tf_vpc[1].id
    tags = {
      "Name" = var.network_details.igw_tags2
    }  
}


