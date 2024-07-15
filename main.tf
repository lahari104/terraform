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
  domain     = "vpc"
  depends_on = [aws_vpc.vpc_tf]

}


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


resource "aws_iam_role" "ec2_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}



resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "ec2-cloudwatch-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}



resource "aws_instance" "pub_inst_tf" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "Lahari"
  security_groups             = [aws_security_group.security_tf.id]
  subnet_id                   = aws_subnet.pub_sub_tf.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
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

data "aws_elb_service_account" "main" {
  depends_on = [null_resource.pvt_tf]
}

resource "aws_s3_bucket" "aws_bucket" {
  bucket        = "access-logs-insignia"
  force_destroy = true
  depends_on    = [null_resource.pvt_tf]
}


resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.aws_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
  depends_on = [aws_s3_bucket.aws_bucket]
}

resource "aws_s3_bucket_acl" "elb_logs_acl" {
  bucket     = aws_s3_bucket.aws_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

data "aws_iam_policy_document" "allow_elb_logging" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.aws_bucket.arn}/AWSLogs/*"]
  }
  depends_on = [aws_s3_bucket_acl.elb_logs_acl]
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket     = aws_s3_bucket.aws_bucket.id
  policy     = data.aws_iam_policy_document.allow_elb_logging.json
  depends_on = [data.aws_iam_policy_document.allow_elb_logging]
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
  depends_on = [aws_s3_bucket_policy.allow_elb_logging]

}

resource "aws_lb" "load_tf" {
  load_balancer_type = "application"
  name               = "tf-lb"
  internal           = false
  subnets            = [aws_subnet.pub_sub_tf.id, aws_subnet.pvt_sub_tf.id]
  security_groups    = [aws_security_group.security_tf.id]
  access_logs {
    bucket  = aws_s3_bucket.aws_bucket.id
    enabled = true
  }
  tags = {
    "Name" = "tf-load-balancer"
  }
  depends_on = [aws_lb_target_group.target_alb_tf]
}


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


resource "aws_flow_log" "flow_log_tf" {
  iam_role_arn    = aws_iam_role.role_tf.arn
  log_destination = aws_cloudwatch_log_group.log_group_tf.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_tf.id
  depends_on      = [aws_cloudwatch_log_group.log_group_tf, aws_iam_role.role_tf]
}

resource "aws_cloudwatch_log_group" "log_group_tf" {
  name         = "log-tf"
  skip_destroy = false
  depends_on   = [aws_lb_listener.lb_logs]

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
  depends_on = [aws_lb_listener.lb_logs]
}

resource "aws_iam_role" "role_tf" {
  name               = "iam-role-tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  depends_on         = [data.aws_iam_policy_document.assume_role]
}

data "aws_iam_policy_document" "policy_doc_tf" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
  depends_on = [aws_lb_listener.lb_logs]
}

resource "aws_iam_role_policy" "role_policy_tf" {
  name       = "iam-role-policy-tf"
  role       = aws_iam_role.role_tf.id
  policy     = data.aws_iam_policy_document.policy_doc_tf.json
  depends_on = [data.aws_iam_policy_document.policy_doc_tf, aws_iam_role.role_tf]
}


resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard_cpu" {
  dashboard_name = "cpu-monitoring-cloudwatch-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "aws_instance.pub_inst_tf"
            ],
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "aws_instance.pvt_inst_tf"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 Instance CPU"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
  depends_on = [aws_iam_role_policy.role_policy_tf]
}


resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard_apache" {
  dashboard_name = "apache-monitoring-cloudwatch-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "ApacheStatus",
              "InstanceId",
              "aws_instance.pub_inst_tf"
            ],
            [
              "AWS/EC2",
              "ApacheStatus",
              "InstanceId",
              "aws_instance.pvt_inst_tf"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Apache Status"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
  depends_on = [aws_cloudwatch_dashboard.cloudwatch_dashboard_cpu]
}


resource "aws_cloudwatch_metric_alarm" "high_cpu_pub" {
  alarm_name          = "high_cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    InstanceId = aws_instance.pub_inst_tf.id
  }
  alarm_actions = []
  depends_on = [aws_cloudwatch_dashboard.cloudwatch_dashboard_apache]
}


resource "aws_cloudwatch_metric_alarm" "high_cpu_pvt" {
  alarm_name          = "high_cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    InstanceId = aws_instance.pvt_inst_tf.id
  }
  alarm_actions = []
  depends_on = [aws_iam_role_policy.cloudwatch_policy]
}


resource "aws_ami_from_instance" "pub_ami" {
  name               = "public-instance-ami"
  source_instance_id = aws_instance.pub_inst_tf.id
  depends_on         = [aws_cloudwatch_metric_alarm.high_cpu_pub]
}


resource "aws_ami_from_instance" "pvt_ami" {
  name               = "pvt-instance-ami"
  source_instance_id = aws_instance.pvt_inst_tf.id
  depends_on         = [aws_ami_from_instance.pub_ami]
}

resource "aws_launch_template" "pub_ins_lt" {
  image_id      = aws_ami_from_instance.pub_ami.id
  instance_type = "t2.micro"
  key_name      = "Lahari"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.security_tf.id]
  }
  placement {
    availability_zone = "us-east-1a"
  }
  depends_on = [aws_ami_from_instance.pub_ami]
}


resource "aws_launch_template" "pvt_ins_lt" {
  image_id      = aws_ami_from_instance.pvt_ami.id
  instance_type = "t2.micro"
  key_name      = "Lahari"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.security_tf.id]
  }
  placement {
    availability_zone = "us-east-1b"
  }
  depends_on = [aws_ami_from_instance.pvt_ami]
}


resource "aws_autoscaling_group" "public_asg" {
  launch_template {
    id      = aws_launch_template.pub_ins_lt.id
    version = "$Latest"
  }
  name                = "public-asg"
  force_delete        = true
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.pub_sub_tf.id]

  tag {
    key                 = "Name"
    value               = "PublicApacheServer"
    propagate_at_launch = true
  }
  depends_on = [aws_launch_template.pub_ins_lt]
}


resource "aws_autoscaling_policy" "public_asg_policy" {
  name                   = "public_asg_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.public_asg.name
  depends_on             = [aws_autoscaling_group.public_asg]
}


resource "aws_cloudwatch_metric_alarm" "high_cpu_pub_asg" {
  alarm_name          = "high_cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.public_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.public_asg_policy.arn]
  depends_on    = [aws_autoscaling_policy.public_asg_policy]
}



resource "aws_autoscaling_group" "private_asg" {
  launch_template {
    id      = aws_launch_template.pvt_ins_lt.id
    version = "$Latest"
  }
  name                = "private-asg"
  force_delete        = true
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.pvt_sub_tf.id]

  tag {
    key                 = "Name"
    value               = "PrivateApacheServer"
    propagate_at_launch = true
  }
  depends_on = [aws_launch_template.pvt_ins_lt]
}


resource "aws_autoscaling_policy" "private_asg_policy" {
  name                   = "private_asg_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.private_asg.name
  depends_on             = [aws_autoscaling_group.private_asg]
}


resource "aws_cloudwatch_metric_alarm" "high_cpu_pvt_asg" {
  alarm_name          = "high_cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.private_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.private_asg_policy.arn]
  depends_on    = [aws_autoscaling_policy.private_asg_policy]
}



### (or)


# resource "aws_ami_from_instance" "ami" {
#   name               = "instance-ami"
#   source_instance_id = aws_instance.pub_inst_tf.id
#   depends_on         = [aws_cloudwatch_metric_alarm.high_cpu_pub]
# }

# resource "aws_launch_template" "ins_lt" {
#   image_id      = aws_ami_from_instance.ami.id
#   instance_type = "t2.micro"
#   key_name      = "Lahari"
#   network_interfaces {
#     associate_public_ip_address = true
#     security_groups             = [aws_security_group.security_tf.id]
#   }
#   placement {
#     availability_zone = "us-east-1a"
#   }
#   depends_on = [aws_ami_from_instance.ami]
# }


# resource "aws_autoscaling_group" "asg" {
#   launch_template {
#     id      = aws_launch_template.ins_lt.id
#     version = "$Latest"
#   }
#   name                = "ASG"
#   force_delete        = true
#   min_size            = 1
#   max_size            = 3
#   desired_capacity    = 1
#   vpc_zone_identifier = [aws_subnet.pub_sub_tf.id, aws_subnet.pvt_sub_tf.id]

#   tag {
#     key                 = "Name"
#     value               = "ApacheServer"
#     propagate_at_launch = true
#   }
#   depends_on = [aws_launch_template.ins_lt]
# }


# resource "aws_autoscaling_policy" "public_asg_policy" {
#   name                   = "asg_policy"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   depends_on             = [aws_autoscaling_group.asg]
# }


# resource "aws_cloudwatch_metric_alarm" "high_cpu_asg" {
#   alarm_name          = "high_cpu"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "70"
#   alarm_description   = "This metric monitors EC2 CPU utilization"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.public_asg.name
#   }
#   alarm_actions = [aws_autoscaling_policy.asg_policy.arn]
#   depends_on    = [aws_autoscaling_policy.asg_policy]
# }