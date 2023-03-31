3 -workspaces
 dev  qa  uat
-------------

1 vpc in dev
1 vpc in qa
2 vpcs in uat
-------------

3 subnets in dev
3 subnets in qa
6 subnets in uat 3 for each vpc
-------------------------------

1 route table and route igw to 0.0.0.0/0 in dev
1 route table and route igw to 0.0.0.0/0 in qa
2 route tables and route igw to 0.0.0.0/0 in uat for each vpc
--------------------------------------------------------------

1 security group in dev vpc
1 security group in qa vpc
2 security groups in uat vpc
-----------------------------

3 instances in dev and install nginx
3 instances in qa and install tree
3 instances for each vpc in uat and install nginx
-------------------------------------------------- 