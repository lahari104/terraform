region = "us-east-1"
details = {
  sub_azs = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
  sub_cidr = [ "10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24" ]
  sub_tags = [ "uat_sub1", "uat_sub2", "uat_sub3" ]
  vpc_cidr = "10.10.0.0/16" 
  vpc_tags = "uat_vpc1"
  uat_sub2_cidrs = [ "10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24" ]
  uat_sub2_tags = [ "uat_sub4", "uat_sub5", "uat_sub6" ]
  uat_sub2_azs = [ "us-east-1d", "us-east-1e", "us-east-1f" ]
  uat_vpc_cidrs = [ "10.10.0.0/16", "10.10.0.0/16" ]
  uat_vpc_tags = [ "uat_vpc1", "uat_vpc2" ]
  uat_igw_tags = [ "uat_igw1", "uat_igw2" ]
  destination_cidr = "0.0.0.0/0"
  rt_uat_tag1 = "uat_rt1"
  rt_uat_tag2 = "uat_rt2" 
  igw_tag = ""
  rt_tag = ""
  sg_tag = "uat_sg_vpc1"
  sg_tag_vpc2 = "uat_sg_vpc2"
}

instance_details = {
  ami_id = "ami-007855ac798b5175e"
  inst_tags = [ "uat_ins1_vpc1", "uat_ins2_vpc1", "uat_ins3_vpc1" ]
  inst_tags_vpc2 = [ "uat_ins1_vpc2", "uat_ins2_vpc2", "uat_ins3_vpc2"  ]
  instance_type = "t2.micro"
  key_pair = "lorry"
  null_trigger = "1.0"
  null_trigger_1 = "1.0"
}