variable "region" {
    type = string
    default = "us-east-1"
}

variable "network_details" {
    type = object({
        vpc_cidrs = string
        sub_cidrs = list(string)
        sub_azs = list(string)
        sub_tags = list(string)
        vpc_tag = string
    })
}