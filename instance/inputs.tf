variable "region" {
    type = string
    default = "us-east-1"
    description = "to create"  
}


variable "network_details" {
    type = object({
        vpc_cidrs = list(string)
        vpc_tags = list(string)
        subnet_cidrs1 = list(string)
        subnet_cidrs2 = list(string)
        subnet_tags1 = list(string)
        subnet_tags2 = list(string)
        azs_subnet1 = list(string)
        azs_subnet2 = list(string)
        igw_tags1 = string
        igw_tags2 = string
    })  
}





