resource "aws_vpc" "workspace_vpc_dev" {
    cidr_block = var.network_details.vpc_cidrs
    tags = {
      "Name" = var.network_details.vpc_tag
    }
    count = "${terraform.workspace == "dev" ? 1 : 0}"
}

resource "aws_subnet" "workspace_subnets_dev" {
    availability_zone = var.network_details.sub_azs[count.index]
    cidr_block = var.network_details.sub_cidrs[count.index]
    vpc_id = aws_vpc.workspace_vpc_dev[0].id
    tags = {
      "Name" = var.network_details.sub_tags[count.index]
    }
    count = "${terraform.workspace == "dev" ? 2 : 0}"  
}


resource "aws_vpc" "workspace_vpc_qa" {
    cidr_block = var.network_details.vpc_cidrs
    tags = {
      "Name" = var.network_details.vpc_tag
    }
    count = "${terraform.workspace == "qa" ? 1 : 0}"
}

resource "aws_subnet" "workspace_subnets_qa" {
    availability_zone = var.network_details.sub_azs[count.index]
    cidr_block = var.network_details.sub_cidrs[count.index]
    vpc_id = aws_vpc.workspace_vpc_qa[0].id
    tags = {
      "Name" = var.network_details.sub_tags[count.index]
    }
    count = "${terraform.workspace == "qa" ? 2 : 0}"  
}

