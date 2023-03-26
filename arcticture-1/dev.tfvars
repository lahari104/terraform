region = "us-east-1"
network_details = {
  availability_zones = [ "us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f" ]
  vpc1_subnet_cidrs = [ "192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"  ]
  vpc1_subnets_tags = [ "app-1", "app-2", "app-3", "db-1", "db-2", "db-3" ]
  vpc_cidrs = [ "192.168.0.0/16", "172.16.0.0/16" ]
  vpc_tags = [ "vpc_1", "vpc_2" ]
  vpc2_subnet_cidrs = [ "172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24", "172.16.4.0/24", "172.16.5.0/24" ]
  vpc2_subnets_tags = [ "db-1", "db-2", "db-3", "app-1", "app-2", "app-3" ]
  vpc1_igw_tag = "igw_1"
  vpc2_igw_tag = "igw-2"
  vpc1_route_table_tags = [ "vpc1_rt_1", "vpc1_rt_2" ]
  vpc2_route_table_tags = [ "vpc2-rt-1", "vpc2_rt_2" ]
  destination_cidr_block = "0.0.0.0/0"
  
}