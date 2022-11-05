# Declare the data source for availablity zone depending on region specified
data "aws_availability_zones" "available" {
  state = "available"
}

#create VPC
resource "aws_vpc" "prodvpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = "prodvpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
#create public and private subnets
resource "aws_subnet" "prod-public" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = var.public_subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "Public subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"

  }
}

resource "aws_subnet" "prod-private" {
  vpc_id            = aws_vpc.prodvpc.id
  cidr_block        = var.private_subnet
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                                        = "Private Subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

#create public_1 and private_1 subnets
resource "aws_subnet" "prodpublic_1" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = var.public1_subnet
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "Public subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"

  }
}

resource "aws_subnet" "prodprivate_1" {
  vpc_id            = aws_vpc.prodvpc.id
  cidr_block        = var.private1_subnet
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name                                        = "Private subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

}
#internet gate way
resource "aws_internet_gateway" "prodgw" {
  vpc_id = aws_vpc.prodvpc.id

  tags = {
    Name = "prodGW"
  }
}

#elastic ip for nat gateway
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.prodgw]

  tags = {
    Name = "NAT Gateway EIP"
  }
}
resource "aws_eip" "nat_eip1" {
  vpc        = true
  depends_on = [aws_internet_gateway.prodgw]
  tags = {
    Name = "NAT Gateway EIP"
  }
}
# Nat gate way
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.prod-public.id

  tags = {
    Name = "Main Nat Gateway"
  }
}
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.prodpublic_1.id

  tags = {
    Name = "Main Nat Gateway_1"
  }
}

#Route Table for Public Subnet
resource "aws_route_table" "prodpublic" {
  vpc_id = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prodgw.id
  }

  tags = {
    Name = "Public Route table"
  }
}
#Associate between public and private Route table
resource "aws_route_table_association" "prod-public" {
  subnet_id      = aws_subnet.prod-public.id
  route_table_id = aws_route_table.prodpublic.id
}
resource "aws_route_table_association" "prodpublic1" {
  subnet_id      = aws_subnet.prodpublic_1.id
  route_table_id = aws_route_table.prodpublic.id
}
#Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route table"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route table"
  }
}
#Associate between public and private Route table
resource "aws_route_table_association" "prodprivate" {
  subnet_id      = aws_subnet.prod-private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "prodprivate1" {
  subnet_id      = aws_subnet.prodprivate_1.id
  route_table_id = aws_route_table.private1.id
}

# create a security group

resource "aws_security_group" "allow_tls" {

  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prodvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#  create EKS cluster

resource "aws_iam_role" "ekscluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eksrole-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ekscluster.name
}


# create cluster

resource "aws_eks_cluster" "nuvei-eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.ekscluster.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.prod-public.id,
      aws_subnet.prod-private.id,
      aws_subnet.prodpublic_1.id,
    aws_subnet.prodprivate_1.id]
    endpoint_public_access = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.eksrole-AmazonEKSClusterPolicy,
  ]
}

#worker nodes

resource "aws_iam_role" "nuvei-eksnode" {
  name = var.eks_node

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eksnode-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nuvei-eksnode.name
}

resource "aws_iam_role_policy_attachment" "eksnode-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nuvei-eksnode.name
}

resource "aws_iam_role_policy_attachment" "eksnode-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nuvei-eksnode.name
}

#create EKS nodes
resource "aws_eks_node_group" "nuveinode_grp" {
  cluster_name    = aws_eks_cluster.nuvei-eks.name
  node_group_name = var.eks_node
  node_role_arn   = aws_iam_role.nuvei-eksnode.arn
  subnet_ids      = [aws_subnet.prod-private.id, aws_subnet.prodprivate_1.id]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }
  # type of AMI associated with eks nodes
  ami_type             = var.node_ami_type
  capacity_type        = "ON_DEMAND"
  disk_size            = 20
  force_update_version = false
  #instance_types = var.instance_type (defaults to t3.medium)

  labels = {
    role = var.eks_node
  }
  depends_on = [
    aws_iam_role_policy_attachment.eksnode-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eksnode-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eksnode-AmazonEC2ContainerRegistryReadOnly,
  ]
}

/* run the following command on profile that created cluster
to give it priviledge to manage cluster
aws eks update-kubeconfig --region us-west-1 --name nuvei_cluster
*/
