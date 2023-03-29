output "Vpc_Id" {
    value = aws_vpc.vpc_tf1.id
}

output "Subnet_Id1" {
    value = aws_subnet.sub_tf[0].id  
}

output "Subnet_Id2" {
    value = aws_subnet.sub_tf[1].id  
}

output "Subnet_Id3" {
    value = aws_subnet.sub_tf[2].id  
}

output "igw_id" {
    value = aws_internet_gateway.igw_tf.id 
}

output "rt_table_id" {
    value = aws_route_table.rt_table_tf.id  
}

output "route_id" {
    value = aws_route.rt_tf.id  
}

output "route_table_ass_id" {
    value = aws_route_table_association.rt_ass[0].id  
}

output "route_table_ass_id1" {
    value = aws_route_table_association.rt_ass[1].id  
}

output "route_table_ass_id2" {
    value = aws_route_table_association.rt_ass[2].id  
}

output "sg_id" {
    value = aws_security_group.sg_tf.id      
}

output "instance_ip1" {
    value = aws_instance.pub_instance.public_ip  
}

output "instance_ip2" {
    value = aws_instance.pvt_instance[0].private_ip  
}

output "instance_ip3" {
    value = aws_instance.pvt_instance[1].private_ip  
}

output "instance_ip_url" {
    value = format("http://%s", aws_instance.pub_instance.public_ip)
}
