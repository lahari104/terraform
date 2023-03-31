variable "region" {
    type = string  
}

variable "details" {
    type = object({
        vpc_cidr = string
        vpc_tags = string
        sub_azs = list(string)
        sub_cidr = list(string)
        sub_tags = list(string)
        uat_vpc_cidrs = list(string)
        uat_vpc_tags = list(string)
        uat_sub2_cidrs = list(string)
        uat_sub2_tags = list(string)
        uat_sub2_azs = list(string)
        igw_tag = string
        uat_igw_tags = list(string)
        destination_cidr = string
        rt_tag = string
        rt_uat_tag1 = string
        rt_uat_tag2 = string
        sg_tag = string
        sg_tag_vpc2 = string
    })   
}

variable "instance_details" {
    type = object({
        ami_id = string
        instance_type = string
        key_pair = string
        inst_tags = list(string)
        inst_tags_vpc2 = list(string)
        null_trigger = string
        null_trigger_1 = string
    })
}