resource "aws_vpc" "vpc_tf1" {
    cidr_block = "10.10.0.0/16"
    tags = {
      "Name" = "vpc1"
    }  
}

resource "aws_subnet" "sub_tf" {
    count = length(var.network_details.sub_azs)
    availability_zone = var.network_details.sub_azs[count.index]
    cidr_block = var.network_details.sub_cidrs[count.index]
    vpc_id = aws_vpc.vpc_tf1.id
    tags = {
      "Name" = var.network_details.sub_tags[count.index]
    }  
}

resource "aws_internet_gateway" "igw_tf" {
    vpc_id = aws_vpc.vpc_tf1.id
    tags = {
      "Name" = "igw"
    }
}

resource "aws_route_table" "rt_table_tf" {
    vpc_id = aws_vpc.vpc_tf1.id
    tags = {
      "Name" = "rt_table"
    }      
}   

resource "aws_route" "rt_tf" {
    route_table_id = aws_route_table.rt_table_tf.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_tf.id  
}

resource "aws_route_table_association" "rt_ass" {
    count = length(var.network_details.subnet_ids)
    subnet_id = aws_subnet.sub_tf[count.index].id
    route_table_id = aws_route_table.rt_table_tf.id  
}



resource "aws_security_group" "sg_tf" {
    description = "allow"
    name = "terraform_sg"
    vpc_id = aws_vpc.vpc_tf1.id
    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]    
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]    
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]    
  } 
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }
    tags = {
      "Name" = "sg_terraform"
    }
}


resource "aws_instance" "pub_instance" {
    ami = var.instance_details.ami_id
    associate_public_ip_address = true
    availability_zone = var.network_details.sub_azs[2]
    instance_type = var.instance_details.instance_type
    key_name = var.instance_details.key_pair
    security_groups = [aws_security_group.sg_tf.id]
    subnet_id = aws_subnet.sub_tf[2].id
    tags = {
      "Name" = var.instance_details.instance_tags_pub
    }
}

resource "aws_instance" "pvt_instance" {
    count = length(var.instance_details.instance_tags)
    ami = var.instance_details.ami_id
    associate_public_ip_address = false
    availability_zone = var.network_details.sub_azs[count.index]
    instance_type = var.instance_details.instance_type
    key_name = var.instance_details.key_pair
    security_groups = [aws_security_group.sg_tf.id]
    subnet_id = aws_subnet.sub_tf[count.index].id
    tags = {
      "Name" = var.instance_details.instance_tags[count.index]
    }
}


resource "null_resource" "shell" {
    triggers = {
      "Name" = var.instance_details.null_trigger
    }
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        host = aws_instance.pub_instance.public_ip
        private_key = file("~/.ssh/id_rsa")
      }
      inline = [
        "sudo apt update",
        "sudo apt install nginx -y",
        "sudo apt install tree -y",
        "sudo apt install net-tools -y"
      ]    
    }
    depends_on = [
      aws_instance.pub_instance
    ]
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        host = aws_instance.pvt_instance[0].private_ip
        private_key = file("~/.ssh/id_rsa")
        bastion_host = aws_instance.pub_instance.public_ip
        # bastion_host_key = file("~/.ssh/id_rsa.pub")
        bastion_user = "ubuntu"
        bastion_private_key = file("~/.ssh/id_rsa")
      }
      inline = [
        "git --version"
      ] 
    }
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        host = aws_instance.pvt_instance[1].private_ip
        private_key = file("~/.ssh/id_rsa")
        bastion_host = aws_instance.pub_instance.public_ip
        # bastion_host_key = file("~/.ssh/id_rsa.pub")
        bastion_user = "ubuntu"
        bastion_private_key = file("~/.ssh/id_rsa")
      }
      inline = [
        "git --version"
      ] 
    }
}



