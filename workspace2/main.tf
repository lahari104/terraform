resource "aws_vpc" "dev_vpc" {
    cidr_block = var.details.vpc_cidr
    tags = {
      "Name" = var.details.vpc_tags
    }  
    count = "${terraform.workspace == "dev" ? 1 : 0}"
}



resource "aws_vpc" "qa_vpc" {
    cidr_block = var.details.vpc_cidr
    tags = {
      "Name" = var.details.vpc_tags
    } 
    count =  "${terraform.workspace == "qa" ? 1 : 0}"
}

resource "aws_vpc" "UAT_vpc" {
    cidr_block = var.details.uat_vpc_cidrs[count.index]
    tags = {
      "Name" = var.details.uat_vpc_tags[count.index]
    }  
    count = "${terraform.workspace == "UAT" ? 2 : 0}"
}


resource "aws_subnet" "dev_subnet" {
    availability_zone = var.details.sub_azs[count.index]
    cidr_block = var.details.sub_cidr[count.index]
    vpc_id = aws_vpc.dev_vpc[0].id
    tags = {
      "Name" = var.details.sub_tags[count.index]
    }
    count = "${terraform.workspace == "dev" ? 3 : 0}"  
}



resource "aws_subnet" "qa_subnet" {
    availability_zone = var.details.sub_azs[count.index]
    cidr_block = var.details.sub_cidr[count.index]
    vpc_id = aws_vpc.qa_vpc[0].id
    tags = {
      "Name" = var.details.sub_tags[count.index]
    }
    count = "${terraform.workspace == "qa" ? 3 : 0}"  
}

resource "aws_subnet" "UAT_vpc1_subnets" {
    availability_zone = var.details.sub_azs[count.index]
    cidr_block = var.details.sub_cidr[count.index]
    vpc_id = aws_vpc.UAT_vpc[0].id
    tags = {
      "Name" = var.details.sub_tags[count.index]
    }
    count = "${terraform.workspace == "UAT" ? 3 : 0}"  
}


resource "aws_subnet" "UAT_vpc2_subnets" {
    availability_zone = var.details.uat_sub2_azs[count.index]
    cidr_block = var.details.uat_sub2_cidrs[count.index]
    vpc_id = aws_vpc.UAT_vpc[1].id
    tags = {
      "Name" = var.details.uat_sub2_tags[count.index]
    }
    count = "${terraform.workspace == "UAT" ? 3 : 0}"  
}

resource "aws_internet_gateway" "dev_igw" {
    vpc_id = aws_vpc.dev_vpc[0].id
    tags = {
      "Name" = var.details.igw_tag
    }
    count = "${terraform.workspace == "dev" ? 1 : 0}"  
}

resource "aws_internet_gateway" "qa_igw" {
    vpc_id = aws_vpc.qa_vpc[0].id
    tags = {
      "Name" = var.details.igw_tag
    }
    count = "${terraform.workspace == "qa" ? 1 : 0}"  
}

resource "aws_internet_gateway" "UAT_igw" {
    vpc_id = aws_vpc.UAT_vpc[count.index].id
    tags = {
      "Name" = var.details.uat_igw_tags[count.index]
    }
    count = "${terraform.workspace == "UAT" ? 2 : 0}"  
}

resource "aws_route_table" "dev_rt" {
    vpc_id = aws_vpc.dev_vpc[0].id
    route {
        cidr_block = var.details.destination_cidr
        gateway_id = aws_internet_gateway.dev_igw[0].id
    }
    tags = {
      "Name" = var.details.rt_tag
    } 
    count = "${terraform.workspace == "dev" ? 1 : 0}" 
}


resource "aws_route_table" "qa_rt" {
    vpc_id = aws_vpc.qa_vpc[0].id
    route {
        cidr_block = var.details.destination_cidr
        gateway_id = aws_internet_gateway.qa_igw[0].id
    }
    tags = {
      "Name" = var.details.rt_tag
    } 
    count = "${terraform.workspace == "qa" ? 1 : 0}" 
}


resource "aws_route_table" "uat_rt_vpc1" {
    vpc_id = aws_vpc.UAT_vpc[0].id
    route {
        cidr_block = var.details.destination_cidr
        gateway_id = aws_internet_gateway.UAT_igw[0].id
    }
    tags = {
      "Name" = var.details.rt_uat_tag1
    }
    count = "${terraform.workspace == "UAT" ? 1 : 0}"  
}

resource "aws_route_table" "uat_rt_vpc2" {
    vpc_id = aws_vpc.UAT_vpc[1].id
    route {
        cidr_block = var.details.destination_cidr
        gateway_id = aws_internet_gateway.UAT_igw[1].id
    }
    tags = {
      "Name" = var.details.rt_uat_tag2
    } 
    count = "${terraform.workspace == "UAT" ? 1 : 0}" 
}


resource "aws_route_table_association" "dev_ass" {
    subnet_id = aws_subnet.dev_subnet[count.index].id
    route_table_id = aws_route_table.dev_rt[0].id 
    count = "${terraform.workspace == "dev" ? 3 : 0}"     
}

resource "aws_route_table_association" "qa_ass" {
    subnet_id = aws_subnet.qa_subnet[count.index].id
    route_table_id = aws_route_table.qa_rt[0].id
    count = "${terraform.workspace == "qa" ? 3 : 0}"    
} 

resource "aws_route_table_association" "uat_ass1" {
    subnet_id = aws_subnet.UAT_vpc1_subnets[count.index].id
    route_table_id = aws_route_table.uat_rt_vpc1[0].id  
    count = "${terraform.workspace == "UAT" ? 3 : 0}"    
    depends_on = [
      aws_route_table.uat_rt_vpc1
    ]
}

resource "aws_route_table_association" "uat_ass2" {
    subnet_id = aws_subnet.UAT_vpc2_subnets[count.index].id
    route_table_id = aws_route_table.uat_rt_vpc2[0].id 
    count = "${terraform.workspace == "UAT" ? 3 : 0}" 
    depends_on = [
      aws_route_table.uat_rt_vpc2
    ]   
}

resource "aws_security_group" "dev_sg" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.dev_vpc[0].id
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.details.destination_cidr]
  }
  tags = {
    Name = var.details.sg_tag
  } 
  count = "${terraform.workspace == "dev" ? 1 : 0}" 
}


resource "aws_security_group" "qa_sg" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.qa_vpc[0].id
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.details.destination_cidr]
  }
  tags = {
    Name = var.details.sg_tag
  } 
  count = "${terraform.workspace == "qa" ? 1 : 0}" 
}
  

  resource "aws_security_group" "uat_sg_vpc1" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.UAT_vpc[0].id
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.details.destination_cidr]
  }
  tags = {
    Name = var.details.sg_tag
  } 
  count = "${terraform.workspace == "UAT" ? 1 : 0}" 
}


resource "aws_security_group" "uat_sg_vpc2" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.UAT_vpc[1].id
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.details.destination_cidr]    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.details.destination_cidr]
  }
  tags = {
    Name = var.details.sg_tag_vpc2
  }  
  count = "${terraform.workspace == "UAT" ? 1 : 0}"
}


resource "aws_instance" "dev_ins" {
  ami = var.instance_details.ami_id
  associate_public_ip_address = true
  availability_zone = var.details.sub_azs[count.index]
  instance_type = var.instance_details.instance_type
  key_name = var.instance_details.key_pair
  security_groups = [aws_security_group.dev_sg[0].id]
  subnet_id = aws_subnet.dev_subnet[count.index].id
  tags = {
    "Name" = var.instance_details.inst_tags[count.index]
  }  
  count = "${terraform.workspace == "dev" ? 3 : 0}"
}



resource "null_resource" "test" {
  triggers = {
    "Name" = var.instance_details.null_trigger
  }
  count = "${terraform.workspace == "dev" ? 3 : 0}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.dev_ins[count.index].public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx php -y"
    ]    
  }
  depends_on = [
    aws_instance.dev_ins    
  ]    
}


resource "aws_instance" "qa_ins" {
  ami = var.instance_details.ami_id
  associate_public_ip_address = true
  availability_zone = var.details.sub_azs[count.index]
  instance_type = var.instance_details.instance_type
  key_name = var.instance_details.key_pair
  security_groups = [aws_security_group.qa_sg[0].id]
  subnet_id = aws_subnet.qa_subnet[count.index].id
  tags = {
    "Name" = var.instance_details.inst_tags[count.index]
  }  
  count = "${terraform.workspace == "qa" ? 3 : 0}"
}

resource "null_resource" "test1_qa" {
  triggers = {
    "Name" = var.instance_details.null_trigger    
  }
  count = "${terraform.workspace == "qa" ? 3 : 0}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.qa_ins[count.index].public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "echo <?php phpinfo() ?> > /var/www/html/info.php"
    ]    
  }
  depends_on = [
    aws_instance.qa_ins    
  ]  
}

resource "aws_instance" "uat_ins1" {
  ami = var.instance_details.ami_id
  associate_public_ip_address = true
  availability_zone = var.details.sub_azs[count.index]
  instance_type = var.instance_details.instance_type
  key_name = var.instance_details.key_pair
  security_groups = [aws_security_group.uat_sg_vpc1[0].id]
  subnet_id = aws_subnet.UAT_vpc1_subnets[count.index].id
  tags = {
    "Name" = var.instance_details.inst_tags[count.index]
  }  
  count = "${terraform.workspace == "UAT" ? 3 : 0}"
}

resource "null_resource" "test_UAT1" {
  triggers = {
    "Name" = var.instance_details.null_trigger    
  }
  count = "${terraform.workspace == "UAT" ? 3 : 0}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.uat_ins1[count.index].public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "echo <?php phpinfo() ?> > /var/www/html/info.php"
    ]    
  }
  depends_on = [
    aws_instance.uat_ins1    
  ]  
}

resource "aws_instance" "uat_ins2" {
  ami = var.instance_details.ami_id
  associate_public_ip_address = true
  availability_zone = var.details.uat_sub2_azs[count.index]
  instance_type = var.instance_details.instance_type
  key_name = var.instance_details.key_pair
  security_groups = [aws_security_group.uat_sg_vpc2[0].id]
  subnet_id = aws_subnet.UAT_vpc2_subnets[count.index].id
  tags = {
    "Name" = var.instance_details.inst_tags_vpc2[count.index]
  }  
  count = "${terraform.workspace == "UAT" ? 3 : 0}"
}

resource "null_resource" "test_UAT2" {
  triggers = {
    "Name" = var.instance_details.null_trigger_1    
  }
  count = "${terraform.workspace == "UAT" ? 3 : 0}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.uat_ins2[count.index].public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "echo <?php phpinfo() ?> > /var/www/html/info.php"
    ]    
  }
  depends_on = [
    aws_instance.uat_ins2    
  ]  
}

