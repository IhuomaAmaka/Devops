region          = "us-east-1"
cidr            = "10.0.0.0/16"
public_subnet   = "10.0.1.0/24"
private_subnet  = "10.0.2.0/24"
public1_subnet  = "10.0.32.0/24"
private1_subnet = "10.0.192.0/24"
#instance_count = 5
instance_type = "t2.medium"
#key_name      = "webapp"
cluster_name  = "nuvei_cluster"
eks_node      = "worker_nodes"
node_ami_type = "AL2_x86_64"

