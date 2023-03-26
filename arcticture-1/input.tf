variable "region" {
    type = string
    description = "Selecting Region" 
}

variable "network_details" {
    type = object({
        vpc_cidrs = list(string)
        vpc_tags = list(string)
        vpc1_subnet_cidrs = list(string)
        availability_zones = list(string)
        vpc1_subnets_tags = list(string)
        vpc2_subnet_cidrs = list(string)
        vpc2_subnets_tags = list(string)
        vpc1_igw_tag = string
        vpc2_igw_tag = string
        vpc1_route_table_tags = list(string)
        vpc2_route_table_tags = list(string) 
        destination_cidr_block = string 

          
    }) 
}