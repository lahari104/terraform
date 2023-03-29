variable "region" {
    type = string
    description = "region"      
}

variable "network_details" {
    type = object({
        sub_azs = list(string)
        sub_cidrs = list(string)
        sub_tags = list(string)
        subnet_ids = list(string)
    })  
}

variable "instance_details" {
    type = object({
        ami_id = string
        key_pair = string
        instance_type = string
        instance_tags = list(string)
        instance_tags_pub = string
        null_trigger = string
    }) 
}