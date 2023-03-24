region = "us-east-1"
network_details = {
  azs_subnet1 = [ "us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f" ]
  azs_subnet2 = [ "us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f" ]
  igw_tags1 = "vpc_igw1" 
  igw_tags2 = "vpc_igw2"
  subnet_cidrs1 = [ "10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24" ]
  subnet_cidrs2 = [ "10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24" ]
  subnet_tags1 = [ "vpc1_sub1", "vpc1_sub2", "vpc1_sub3", "vpc1_sub4", "vpc1_sub5", "vpc1_sub6" ]
  subnet_tags2 = [ "vpc2_sub1", "vpc2_sub2", "vpc2_sub3", "vpc2_sub4", "vpc2_sub5", "vpc2_sub6" ]
  vpc_cidrs = [ "10.1.0.0/16", "10.2.0.0/16" ]
  vpc_tags = [ "vpc1", "vpc2" ]
}