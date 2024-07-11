resource "aws_vpc" "vpc_tf" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name" = "Vpc"
  }

}

resource "aws_subnet" "pub_sub_tf" {
  availability_zone = "us-east-1a"
  cidr_block        = "192.168.1.0/24"
  vpc_id            = aws_vpc.vpc_tf.id
  tags = {
    "Name" = "Pub_subnet"
  }
  depends_on = [aws_vpc.vpc_tf]

}


resource "aws_subnet" "pvt_sub_tf" {
  availability_zone = "us-east-1b"
  cidr_block        = "192.168.2.0/24"
  vpc_id            = aws_vpc.vpc_tf.id
  tags = {
    "Name" = "Pvt_subnet"
  }
  depends_on = [aws_vpc.vpc_tf]
}


resource "aws_internet_gateway" "igw_tf" {
  vpc_id = aws_vpc.vpc_tf.id
  tags = {
    "Name" = "internet-gateway"
  }
  depends_on = [aws_vpc.vpc_tf]
}


resource "aws_route_table" "pub_rtable_tf" {
  vpc_id = aws_vpc.vpc_tf.id
  tags = {
    "Name" = "pub_rt"
  }
  depends_on = [aws_vpc.vpc_tf]
}

resource "aws_route_table" "pvt_rtable_tf" {
  vpc_id = aws_vpc.vpc_tf.id
  tags = {
    "Name" = "pvt_rt"
  }
  depends_on = [aws_vpc.vpc_tf]
}



resource "aws_route" "rt_tf" {
  route_table_id         = aws_route_table.pub_rtable_tf.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_tf.id
  depends_on             = [aws_internet_gateway.igw_tf]
}

resource "aws_route_table_association" "pub_rt_assoc_tf" {
  subnet_id      = aws_subnet.pub_sub_tf.id
  route_table_id = aws_route_table.pub_rtable_tf.id
  depends_on     = [aws_route_table.pub_rtable_tf, aws_subnet.pub_sub_tf]
}


resource "aws_route_table_association" "pvt_rt_assoc_tf" {
  subnet_id      = aws_subnet.pvt_sub_tf.id
  route_table_id = aws_route_table.pvt_rtable_tf.id
  depends_on     = [aws_route.pvt_rt_tf, aws_subnet.pvt_sub_tf]
}


resource "aws_eip" "nat_eip_tf" {
  #   instance = aws_instance.pvt_inst_tf.id
  domain     = "vpc"
  depends_on = [aws_vpc.vpc_tf]

}

# resource "aws_eip_association" "pvt_eip_ass_tf" {
#   instance_id   = aws_instance.pvt_inst_tf.id
#   allocation_id = aws_eip.nat_eip_tf.id

# }

resource "aws_nat_gateway" "pvt_nat_tf" {
  allocation_id = aws_eip.nat_eip_tf.id
  subnet_id     = aws_subnet.pub_sub_tf.id
  tags = {
    "Name" = "Pvt-nat"
  }
  depends_on = [aws_eip.nat_eip_tf]

}

resource "aws_route" "pvt_rt_tf" {
  route_table_id         = aws_route_table.pvt_rtable_tf.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pvt_nat_tf.id
  depends_on             = [aws_nat_gateway.pvt_nat_tf]
}


resource "aws_security_group" "security_tf" {
  description = "alltcp"
  name        = "Security"
  tags = {
    "Name" = "Security group"
  }
  vpc_id = aws_vpc.vpc_tf.id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.vpc_tf]
}




resource "aws_instance" "pub_inst_tf" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "Lahari"
  security_groups             = [aws_security_group.security_tf.id]
  subnet_id                   = aws_subnet.pub_sub_tf.id
  tags = {
    "Name" = "Pub_Instance"
  }
  depends_on = [aws_route_table_association.pub_rt_assoc_tf]
}


resource "aws_instance" "pvt_inst_tf" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  availability_zone           = "us-east-1b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "Lahari"
  security_groups             = [aws_security_group.security_tf.id]
  subnet_id                   = aws_subnet.pvt_sub_tf.id
  tags = {
    "Name" = "Pvt_Instance"
  }
  depends_on = [aws_route_table_association.pvt_rt_assoc_tf]
}


resource "null_resource" "pub_tf" {
  triggers = {
    "Name" = "1.1"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.pub_inst_tf.public_ip
  }


  provisioner "file" {
    source      = "ec2.sh"
    destination = "./ec2.sh"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./ec2.sh",
      "sh ec2.sh",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }


  depends_on = [aws_instance.pub_inst_tf]
}


resource "null_resource" "pvt_tf" {
  triggers = {
    "Name" = "1.1"
  }
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("~/.ssh/id_rsa")
    host                = aws_instance.pvt_inst_tf.private_ip
    bastion_host        = aws_instance.pub_inst_tf.public_ip
    bastion_private_key = file("~/.ssh/id_rsa")
    bastion_user        = "ubuntu"
    bastion_host_key    = file("~/.ssh/id_rsa.pub")
  }

  provisioner "file" {
    source      = "ec2.sh"
    destination = "./ec2.sh"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./ec2.sh",
      "sh ec2.sh",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }

  depends_on = [aws_instance.pub_inst_tf, aws_instance.pvt_inst_tf]

}

data "aws_s3_bucket" "aws_bucket" {
  bucket = "access-logs-insignia"
  
}


resource "aws_lb_target_group" "target_alb_tf" {
  name        = "target-grp-lb"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_tf.id
  health_check {
    enabled  = true
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
  depends_on = [data.aws_s3_bucket.aws_bucket]

}

resource "aws_lb" "load_tf" {
  load_balancer_type = "application"
  name               = "tf-lb"
  internal           = false
  subnets            = [aws_subnet.pub_sub_tf.id, aws_subnet.pvt_sub_tf.id]
  security_groups    = [aws_security_group.security_tf.id]
  access_logs {
    bucket  = data.aws_s3_bucket.aws_bucket.bucket
    enabled = true
  }
  tags = {
    "Name" = "tf-load-balancer"
  }
  depends_on = [data.aws_s3_bucket.aws_bucket, aws_lb_target_group.target_alb_tf]

}

# resource "aws_s3_bucket" "s3_tf" {
#   bucket = "bucket-load-balancer-logs"
#   tags = {
#     "Name" = "lb-logs"
#   }
#   depends_on = [ null_resource.pvt_tf ]
# }


# resource "aws_s3_bucket_policy" "alb_logs_policy" {
#   bucket = aws_s3_bucket.s3_tf.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
#         },
#         "Action": "s3:PutObject",
#         "Resource": ""
#       }
#     ]
#   })
#   depends_on = [ aws_s3_bucket.s3_tf ]
# }

# Create S3 Bucket for ALB Logs
# resource "aws_s3_bucket" "bucket_tf" {
#   bucket = "bucket-load-balancer-logs"
#   # aws_s3_bucket_acl    = "private"


#   tags = {
#     Name = "my-alb-logs-bucket"
#   }
#   depends_on = [ null_resource.pvt_tf ]
# }

# data "aws_elb_service_account" "elb_acc" {
#   depends_on = [ aws_s3_bucket.bucket_tf ]
  
# }

# resource "aws_iam_role" "alb_role" {
#   name = "alb-logs-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "alb_s3_policy" {
#   name        = "ALBAccessLogsPolicy"
#   path        = "/"
#   description = "Allows ALB to write access logs to S3 bucket"

#   policy = jsonencode({
#     "Version" = "2012-10-17",
#     "Statement" = [
#       {
#         "Effect" = "Allow",
#         "Action" = [
#           "s3:ListAllMyBuckets"
#         ],
#         "Resource" = "*"
#       },
#       {
#         "Effect" = "Allow",
#         "Action" = [
#           "s3:PutObject",
#           "s3:PutObjectAcl"
#         ],
#         "Resource" = "${aws_s3_bucket.bucket_tf.arn}/*"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "alb_s3_policy" {
#   name        = "policy"
#   description = "My test policy"

#   policy = <<EOT
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:ListAllMyBuckets"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     },
#     {
#       "Action": [
#         "s3:*"
#       ],
#       "Effect": "Allow",
#       "Resource": "${aws_s3_bucket.bucket_tf.arn}"
#     }
#   ]

# }
# EOT
# depends_on = [ aws_s3_bucket.bucket_tf ]
# }

# resource "aws_iam_role" "alb_role" {
#   name = "alb-logs-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }


# resource "aws_iam_role_policy_attachment" "alb_s3_policy_attachment" {
#   role       = aws_iam_role.alb_role.name
#   policy_arn = aws_iam_policy.alb_s3_policy.arn
# }



# resource "aws_s3_bucket_policy" "bucket_policy_tf" {
#   bucket = aws_s3_bucket.bucket_tf.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": "${data.aws_elb_service_account.elb_acc.arn}"

#         },
#         "Action": [
#           "s3:PutObject",
#           "s3:ListAllMyBuckets",
#           "s3:GetBucketAcl",
#           "s3:*"
#         ],
#         "Resource": [
#           "${aws_s3_bucket.bucket_tf.arn}",
#           "${aws_s3_bucket.bucket_tf.arn}/my-job/AWSLogs/*"
#           ]
#       }
#     ]
#   })
#   depends_on = [aws_s3_bucket.bucket_tf]
# }


resource "aws_lb_target_group_attachment" "tg_attach_pub_tf" {
  target_group_arn = aws_lb_target_group.target_alb_tf.arn
  target_id        = aws_instance.pub_inst_tf.id
  port             = 80
  depends_on       = [aws_lb_target_group.target_alb_tf]
}

resource "aws_lb_target_group_attachment" "tg_attach_pvt_tf" {
  target_group_arn = aws_lb_target_group.target_alb_tf.arn
  target_id        = aws_instance.pvt_inst_tf.id
  port             = 80
  depends_on       = [aws_lb_target_group.target_alb_tf]
}


# Enable ALB Access Logging
resource "aws_lb_listener" "lb_logs" {
  load_balancer_arn = aws_lb.load_tf.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_alb_tf.arn
  }
  depends_on = [aws_lb.load_tf, aws_lb_target_group.target_alb_tf, aws_lb_target_group_attachment.tg_attach_pvt_tf]
}




# resource "aws_lb_listener" "listener_tf" {
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.target_alb_tf.arn
#   }
#   load_balancer_arn = aws_lb.load_tf.arn
#   port = 80
#   protocol = "HTTP"
#   depends_on = [ aws_lb.load_tf, aws_lb_target_group.target_alb_tf ]

# }