##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  version    = "~>2.0"
  region     = var.region
  profile    = "default"
}

##################################################################################
# DATA SOURCES
##################################################################################

data "aws_availability_zones" "azs" {}

data "aws_ami" "centos-linux" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  # most_recent = true
  # owners      = ["679593333241"]

  # filter {
  #   name   = "name"
  #   values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  # }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##################################################################################
# LOCAL
##################################################################################

# the default username for AMI
locals {
  vm_user = "ubuntu"
}

##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

  tags = {
    Name        = "default VPC for us-east-1a"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)

  tags = {
    Name        = "default subnet for us-east-1a"
    Environment = "${terraform.workspace}"
    Tier        = "Public"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1)

  tags = {
    Name        = "default subnet for us-east-1b"
    Environment = "${terraform.workspace}"
    Tier        = "Public"
  }
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = element(data.aws_availability_zones.azs.names, 2)

  tags = {
    Name        = "default subnet for us-east-1c"
    Environment = "${terraform.workspace}"
    Tier        = "Public"
  }
}

# resource "tls_private_key" "tlsauth" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "ec2key" {
#   # key_name   = var.key_name
#   key_name   = "${var.key_name}-${terraform.workspace}"
#   public_key = tls_private_key.tlsauth.public_key_openssh
#   tags = {
#     Name = "ansible-key-${terraform.workspace}"
#   }
# }

# resource "null_resource" "get_keys" {

#   provisioner "local-exec" {
#     command     = "echo '${tls_private_key.tlsauth.public_key_openssh}' > ./kubernetes-public-key-${terraform.workspace}.rsa"
#   }

#   provisioner "local-exec" {
#     command     = "echo '${tls_private_key.tlsauth.private_key_pem}' > ./kubernetes-key-${terraform.workspace}.pem"
#   }

#   provisioner "local-exec" {
#     command     = "chmod 600 ./kubernetes-key-${terraform.workspace}.pem"
#   }

# }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "2.33.0"

#   name = "dev-vpc"
#   cidr = var.vpc_cidr_range

#   azs = slice(data.aws_availability_zones.azs.names, 0, 2) # Grabbing 2 AZs from the list of AZs

#   # Public Subnets
#   public_subnets = var.public_subnets

#   # Database Subnets
#   database_subnets = var.database_subnets
#   database_subnet_group_tags = {
#     subnet_type = "database"
#   }

#   tags = {
#     Environment = "dev"
#     Region      = "east"
#     Team        = "infra"
#   }

# }

resource "aws_security_group" "master_node_rules" {
  name        = "master_node_rules-${terraform.workspace}"
  description = "Allow ports for master nodes"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master_node" {
  ami           = data.aws_ami.centos-linux.id
  instance_type = var.image_type
  # key_name               = aws_key_pair.ec2key.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.master_node_rules.id]
  # subnet_id = aws_default_subnet.default_az1.id
  subnet_id = element(list(aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id), count.index)
  count     = length(var.master_node_names)
  # count = 1

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.vm_user
    private_key = file(var.private_key_path)

  }

  lifecycle {
    create_before_destroy = true
  }

  # force Terraform to wait until a connection is made, prevent Ansible from failing when trying to provision
  provisioner "remote-exec" {
    inline = ["echo Successfully Connected"]
  }

  provisioner "local-exec" {
    [for master in aws_instance.master_node:
    # command = "sleep 120; ansible-playbook -i '${aws_instance.master_node.*.public_ip}' k8s-playbook.yml"
    command = "sleep 120; ansible-playbook -i '${aws_instance.master_node.public_ip}' k8s-playbook.yml"
    ]
  }

  tags = {
    Name        = "${var.master_node_names[count.index]}${count.index + 1}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "worker_node_rules" {
  name        = "worker_node_rules-${terraform.workspace}"
  description = "Allow ports for worker nodes"
  vpc_id      = aws_default_vpc.default.id

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
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker_nodes" {
  ami           = data.aws_ami.centos-linux.id
  instance_type = var.image_type
  # key_name               = aws_key_pair.ec2key.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.worker_node_rules.id]
  # subnet_id = aws_default_subnet.default_az1.id
  subnet_id = element(list(aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id), count.index)
  count     = length(var.worker_node_names)
  # count = 2

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.vm_user
    private_key = file(var.private_key_path)

  }

  lifecycle {
    create_before_destroy = true
  }

  # force Terraform to wait until a connection is made, prevent Ansible from failing when trying to provision
  provisioner "remote-exec" {
    inline = ["echo Successfully connected"]
  }

  tags = {
    # Name = "web-${count.index}-${terraform.workspace}"
    Name        = "${var.worker_node_names[count.index]}${count.index + 1}"
    Environment = "${terraform.workspace}"
  }
}

# resource "aws_iam_instance_profile" "customssmprofile" {
#   name = "customssmprofile-${terraform.workspace}"
#   role = aws_iam_role.customssmrole.name
# }

# resource "aws_iam_role" "customssmrole" {
#   name = "customssmrole-${terraform.workspace}"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# tags = {
#       Environment = "${terraform.workspace}"
#   }
# }

# data "aws_iam_policy" "awsssmmanagedinstancecore" {
#   arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "awsssmmanaged-policy-attach" {
#   role       = aws_iam_role.customssmrole.name
#   policy_arn = data.aws_iam_policy.awsssmmanagedinstancecore.arn
# }


