###################################
### 1. VPC and Subnets Creation ###
###################################

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
  depends_on = [aws_vpc.main]
}

# Create Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet"
  }
  depends_on = [aws_vpc.main]
}

######################################
### 2. Internet Gateway and Routes ###
######################################

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-igw"
  }
  depends_on = [aws_vpc.main]
}

# Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
  depends_on = [aws_vpc.main]
}

# Create Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route" "pub_rt" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public_rt]


}


# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_route.pub_rt]
}


#################################
### 3. NAT Gateway and EIP ###
#################################

# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "my-nat-gw"
  }
  depends_on = [aws_eip.nat_eip, aws_subnet.public]
}

# Add route in Private Route Table to NAT Gateway
resource "aws_route" "private_subnet_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  depends_on             = [aws_nat_gateway.nat_gw, aws_route_table.private_rt]
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
  depends_on     = [aws_route.private_subnet_nat_route]
}


#####################################
### 4. EC2 Instances and Apache ###
#####################################

# EC2 Instance Security Group
resource "aws_security_group" "instance_sg" {
  name   = "instance-sg"
  vpc_id = aws_vpc.main.id

  # Allow HTTP & HTTPS inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH inbound traffic for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
  depends_on = [aws_route_table_association.private_subnet_assoc]
}

# EC2 Instance in Public Subnet
resource "aws_instance" "public_instance" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = "office-mac"
  security_groups             = [aws_security_group.instance_sg.id]
  depends_on                  = [aws_security_group.instance_sg]
  associate_public_ip_address = true
  tags = {
    Name = "public-instance"
  }
}


resource "null_resource" "public_null" {
  triggers = {
    "Name" = "1.0"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.public_instance.public_ip
  }

  provisioner "file" {
    source      = "./ec2.sh"
    destination = "./ec2.sh"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"
  }


  provisioner "remote-exec" {
    inline = [
      "sh ec2.sh",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }
  depends_on = [aws_instance.public_instance]

}



# EC2 Instance in Private Subnet
resource "aws_instance" "private_instance" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  key_name                    = "office-mac"
  security_groups             = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "private-instance"
  }
  depends_on = [null_resource.public_null]
}


resource "null_resource" "private_null" {
  triggers = {
    "Name" = "1.0"
  }
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("~/.ssh/id_rsa")
    host                = aws_instance.private_instance.private_ip
    bastion_host        = aws_instance.public_instance.public_ip
    bastion_host_key    = file("~/.ssh/id_rsa.pub")
    bastion_user        = "ubuntu"
    bastion_private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    source      = "./ec2.sh"
    destination = "./ec2.sh"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"
  }


  provisioner "remote-exec" {
    inline = [
      "sh ec2.sh",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }
  depends_on = [aws_instance.private_instance]

}


# #########################################
# ### 6. S3 Bucket for ALB Access Logs ###
# #########################################

# Create S3 Bucket for ALB Logs
# resource "aws_s3_bucket" "alb_logs_bucket" {
#   bucket = "access-logs-bucket-tarun"
#   tags = {
#     Name = "access-logs-bucket-tarun"
#   }
#   depends_on = [null_resource.private_null]
# }

# data "aws_elb_service_account" "acc_id" {
#     depends_on = [ aws_s3_bucket.alb_logs_bucket ]
# }

# data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket_policy" "alb_logs_bucket_policy" {
#   bucket = aws_s3_bucket.alb_logs_bucket.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#         "Effect": "Allow",
#         "Principal": {
#             "AWS": [
#                 "${data.aws_elb_service_account.acc_id.id}:root"
#             ]
#         },
#         "Action": ["s3:PutObject"],
#         "Resource": "${aws_s3_bucket.alb_logs_bucket.arn}/AWSLogs/${data.aws_elb_service_account.acc_id.id}/*"
#         }
#     ]
# })
#   depends_on = [ aws_s3_bucket.alb_logs_bucket ]
# }



data "aws_s3_bucket" "aws_bucket" {
  bucket = "access-logs-insignia"
}

# type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_elb_service_account.elb_account_id.id}:root"]
######################################
### 5. Application Load Balancer ###
######################################

# Create ALB Target Group
resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "target-group"
  }
  depends_on = [null_resource.private_null]
}


# Create ALB
resource "aws_lb" "tf_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]
  access_logs {
    bucket = data.aws_s3_bucket.aws_bucket.bucket
    enabled = true
  }

  tags = {
    Name = "my-alb"
  }
  depends_on = [data.aws_s3_bucket.aws_bucket]
}


# Register Public Instance with ALB Target Group
resource "aws_lb_target_group_attachment" "public_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.public_instance.id
  port             = 80
  depends_on       = [aws_lb_target_group.target_group]
}


# Register Private Instance with ALB Target Group
resource "aws_lb_target_group_attachment" "private_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.private_instance.id
  port             = 80
  depends_on       = [aws_lb_target_group.target_group]
}



# Enable ALB Access Logging
resource "aws_lb_listener" "tf_alb_logs" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  depends_on = [ aws_lb_target_group_attachment.private_attachment ]
}

# ###########################################
# ### 7. CloudWatch Logs for VPC Flow Logs ###
# ###########################################

# # Create CloudWatch Logs Group for VPC Flow Logs
# resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
#   name = "/aws/vpc/flow-logs"

#   retention_in_days = 7  # Example retention period

#   tags = {
#     Name = "vpc-flow-logs"
#   }
# }

# # Create VPC Flow Logs
# resource "aws_flow_log" "vpc_flow_logs" {
#   log_group_name              = aws_cloudwatch_log_group.vpc_flow_logs.name
#   subnet_id                   = aws_subnet.id
#   traffic_type                = "ALL"
#   log_destination_type        = "cloud-watch-logs"
# }

# ##########################################
# ### 8. CloudWatch Dashboard Creation ###
# ##########################################

# # Create CloudWatch Dashboard
# resource "aws_cloudwatch_dashboard" "example" {
#   dashboard_name = "my-cloudwatch-dashboard"

#   dashboard_body = <<EOF
# {
#   "widgets": [
#     {
#       "type": "metric",
#       "x": 0,
#       "y": 0,
#       "width": 12,
#       "height": 6,
#       "properties": {
#         "metrics": [
#           [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.public_instance.id}" ],
#           [ "...", "InstanceId", "${aws_instance.private_instance.id}" ]
#         ],
#         "title": "CPU Utilization",
#         "period": 300,
#         "stat": "Average",
#         "region": "us-east-1"
#       }
#     },
#     {
#       "type": "metric",
#       "x": 0,
#       "y": 6,
#       "width": 12,
#       "height": 6,
#       "properties": {
#         "metrics": [
#           [ "AWS/EC2", "StatusCheckFailed_Instance", "InstanceId", "${aws_instance.public_instance.id}" ],
#           [ "...", "InstanceId", "${aws_instance.private_instance.id}" ]
#         ],
#         "title": "Apache Service Status",
#         "period": 300,
#         "stat": "Sum",
#         "region": "us-east-1"
#       }
#     }
#   ]
# }
# EOF
# }

# #############################################
# ### 9. Auto Scaling Group for CPU Utilization ###
# #############################################

# # Create Launch Configuration for Auto Scaling Group
# resource "aws_launch_configuration" "example" {
#   name_prefix          = "my-asg-lc-"
#   image_id             = "ami-12345678"  # Replace with your desired AMI ID
#   instance_type        = "t2.micro"
#   security_groups      = [aws_security_group.instance_sg.id]

#   lifecycle {
#     create_before_destroy = true
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo apt-get update
#               sudo apt-get install -y apache2
#               echo '<html><body><h1>Hello, Auto Scaling Instance!</h1></body></html>' > /var/www/html/index.html
#               sudo systemctl enable apache2
#               sudo systemctl start apache2
#               EOF
# }

# # Create Auto Scaling Group
# resource "aws_autoscaling_group" "example" {
#   launch_configuration = aws_launch_configuration.example.id
#   desired_capacity      = 1
#   min_size              = 1
#   max_size              = 3  # Example max size

#   vpc_zone_identifier   = [aws_subnet.public.id]

#   tag {
#     key                 = "Name"
#     value               = "my-asg"
#     propagate_at_launch = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_lb.example]  # Ensure ALB is created first
# }

# # Create Scaling Policy based on CPU Utilization
# resource "aws_autoscaling_policy" "cpu_utilization" {
#   name                   = "scale-on-cpu"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300  # Example cooldown period
#   policy_type            = "SimpleScaling"
#   autoscaling_group_name = aws_autoscaling_group.example.name

#   metric_aggregation_type = "Average"

#   step_adjustment {
#     metric_interval_lower_bound = 0
#     scaling_adjustment          = 1
#   }

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#   }
# }

