region = "us-east-1"
network_details = {
  sub_azs = [ "us-east-1a", "us-east-1b" ]
  sub_cidrs = [ "192.168.0.0/24", "192.168.1.0/24" ]
  sub_tags = [ "qa_sub_1", "qa_sub_2" ]
  vpc_cidrs = "192.168.0.0/16"
  vpc_tag = "qa_vpc"
}