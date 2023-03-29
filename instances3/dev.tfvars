region = "us-west-2"
network_details = {
    sub_azs = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
    sub_cidrs = [ "10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24" ]
    sub_tags = [ "subnet1", "subnet2", "subnet3" ]  
    subnet_ids =  [ "sub_id1", "sub_id2", "sub_id3" ]
}
instance_details = {
  ami_id = "ami-0fcf52bcf5db7b003"
  instance_tags = [ "pvt_1", "pvt_2" ]
  instance_type = "t2.micro"
  key_pair = "oregon"
  instance_tags_pub = "pub_1"
  null_trigger = "1.1"
}