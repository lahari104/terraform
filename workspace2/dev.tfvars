region = "us-west-2"
details = {
  sub_azs = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  sub_cidr = [ "192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24" ]
  sub_tags = [ "dev_sub1", "dev_sub2", "dev_sub3" ]
  vpc_cidr = "192.168.0.0/16" 
  vpc_tags = "dev_vpc1"
  igw_tag = "dev_igw"
  uat_igw_tags = [ "" ]
  uat_sub2_azs = [ "" ]
  uat_sub2_cidrs = [ "" ]
  uat_sub2_tags = [ "" ]
  uat_vpc_cidrs = [ "" ]
  uat_vpc_tags = [ "" ]
  destination_cidr = "0.0.0.0/0"
  rt_tag = "dev_rt"
  rt_uat_tag1 = ""
  rt_uat_tag2 = ""
  sg_tag = "dev_sg" 
  sg_tag_vpc2 = ""
}

instance_details = {
  ami_id = "ami-0fcf52bcf5db7b003"
  inst_tags = [ "inst1_dev", "inst2_dev", "inst3_dev" ]
  instance_type = "t3.micro"
  key_pair = "lorry"
  inst_tags_vpc2 = [""]
  null_trigger = "1.1"
  null_trigger_1 = ""
}