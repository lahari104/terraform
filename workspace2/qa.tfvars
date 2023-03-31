region = "ap-south-1"
details = {
  destination_cidr = "0.0.0.0/0"
  igw_tag = "qa_igw"
  rt_tag = "qt_rt"
  rt_uat_tag1 = "value"
  rt_uat_tag2 = "value"
  sub_azs = [ "ap-south-1a", "ap-south-1b", "ap-south-1c" ]
  sub_cidr = [ "172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24" ]
  sub_tags = [ "qa_sub_1", "qa_sub_2", "qa_sub_3" ]
  uat_igw_tags = [ "value" ]
  uat_sub2_azs = [ "value" ]
  uat_sub2_cidrs = [ "value" ]
  uat_sub2_tags = [ "value" ]
  uat_vpc_cidrs = [ "value" ]
  uat_vpc_tags = [ "value" ]
  vpc_cidr = "172.16.0.0/16"
  vpc_tags = "qa_vpc"
  sg_tag = "sg_qa"
  sg_tag_vpc2 = ""
}

instance_details = {
  ami_id = "ami-02eb7a4783e7e9317"
  inst_tags = [ "qa_ins1", "qa_ins2", "qa_ins3" ]
  inst_tags_vpc2 = [ "" ]
  instance_type = "t3.small"
  key_pair = "lorry"
  null_trigger = "1.0"
  null_trigger_1 = ""
}