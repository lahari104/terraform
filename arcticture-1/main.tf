resource "aws_vpc" "tf_vpc" {
  count      = length(var.network_details.vpc_cidrs)
  cidr_block = var.network_details.vpc_cidrs[count.index]
  tags = {
    "Name" = var.network_details.vpc_tags[count.index]
  }
}


resource "aws_subnet" "vpc1_subnets" {
  count             = length(var.network_details.vpc1_subnet_cidrs)
  cidr_block        = var.network_details.vpc1_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.tf_vpc[0].id
  availability_zone = var.network_details.availability_zones[count.index]
  tags = {
    "Name" = var.network_details.vpc1_subnets_tags[count.index]
  }
}

resource "aws_subnet" "vpc2_subnets" {
  count             = length(var.network_details.vpc2_subnet_cidrs)
  cidr_block        = var.network_details.vpc2_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.tf_vpc[1].id
  availability_zone = var.network_details.availability_zones[count.index]
  tags = {
    "Name" = var.network_details.vpc2_subnets_tags[count.index]
  }
}


resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.tf_vpc[0].id
  tags = {
    "Name" = var.network_details.vpc1_igw_tag
  }
}



resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.tf_vpc[1].id
  tags = {
    "Name" = var.network_details.vpc2_igw_tag
  }
}


resource "aws_route_table" "tf_route_table1" {
  count = length(var.network_details.vpc1_route_table_tags)
  vpc_id = aws_vpc.tf_vpc[0].id
  tags = {
    "Name" = var.network_details.vpc1_route_table_tags[count.index]
  }
}


resource "aws_route_table" "tf_route_table2" {
  count = length(var.network_details.vpc2_route_table_tags)
  vpc_id = aws_vpc.tf_vpc[1].id
  tags = {
    "Name" = var.network_details.vpc2_route_table_tags[count.index]
  }
}


resource "aws_route" "tf_rt1" {
  route_table_id = aws_route_table.tf_route_table1[0].id
  destination_cidr_block = var.network_details.destination_cidr_block
  gateway_id =  aws_internet_gateway.igw1.id
}

resource "aws_route" "tf_rt2" {
  route_table_id = aws_route_table.tf_route_table1[1].id
  destination_cidr_block = var.network_details.destination_cidr_block
  gateway_id = aws_internet_gateway.igw1.id 
}

resource "aws_route" "tf_rt3" {
  route_table_id = aws_route_table.tf_route_table2[0].id
  destination_cidr_block = var.network_details.destination_cidr_block
  gateway_id = aws_internet_gateway.igw2.id 
}

resource "aws_route" "tf_rt4" {
  route_table_id = aws_route_table.tf_route_table2[1].id
  destination_cidr_block = var.network_details.destination_cidr_block
  gateway_id = aws_internet_gateway.igw2.id  
}


resource "aws_route_table_association" "vpc_1_rt_associate_1" {
  count = length(var.network_details.vpc_cidrs)
  subnet_id = aws_subnet.vpc1_subnets[count.index].id
  route_table_id = aws_route_table.tf_route_table1[0].id
  depends_on = [
    aws_route_table.tf_route_table1
  ]
}

resource "aws_route_table_association" "vpc_1_rt_associate_2" {
  subnet_id = aws_subnet.vpc1_subnets[3].id
  route_table_id = aws_route_table.tf_route_table1[0].id
  depends_on = [
    aws_route_table.tf_route_table1
  ]
}

resource "aws_route_table_association" "vpc_1_rt_associate_3" {
  subnet_id = aws_subnet.vpc1_subnets[2].id
  route_table_id = aws_route_table.tf_route_table1[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}


resource "aws_route_table_association" "vpc_1_rt_associate_4" {
  subnet_id = aws_subnet.vpc1_subnets[4].id
  route_table_id = aws_route_table.tf_route_table1[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}

resource "aws_route_table_association" "vpc_1_rt_associate_5" {
  subnet_id = aws_subnet.vpc1_subnets[5].id
  route_table_id = aws_route_table.tf_route_table1[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}


resource "aws_route_table_association" "vpc_2_rt_associate_1" {
  count = length(var.network_details.vpc_cidrs)
  subnet_id = aws_subnet.vpc2_subnets[count.index].id
  route_table_id = aws_route_table.tf_route_table2[0].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}

resource "aws_route_table_association" "vpc_2_rt_associate_2" {
  subnet_id = aws_subnet.vpc2_subnets[3].id
  route_table_id = aws_route_table.tf_route_table2[0].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}

resource "aws_route_table_association" "vpc_2_rt_associate_3" {
  subnet_id = aws_subnet.vpc2_subnets[2].id
  route_table_id = aws_route_table.tf_route_table2[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}


resource "aws_route_table_association" "vpc_2_rt_associate_4" {
  subnet_id = aws_subnet.vpc2_subnets[4].id
  route_table_id = aws_route_table.tf_route_table2[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}

resource "aws_route_table_association" "vpc_2_rt_associate_5" {
  subnet_id = aws_subnet.vpc2_subnets[5].id
  route_table_id = aws_route_table.tf_route_table2[1].id
  depends_on = [
    aws_route_table.tf_route_table2
  ]
}
