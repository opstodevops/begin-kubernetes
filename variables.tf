##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {

}

variable "aws_secret_key" {

}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
 type = string
 default = "kubernetes-key"
}

variable "private_key_path" {
  default = "/home/cloud_user/tf-kubernetes-dev/stage-dev/kubernetes-key.pem"
}

variable "master_node_names" {
  description = "names of master nodes for k8s cluster"
  type        = list(string)
  default     = ["master"]
}

variable "worker_node_names" {
  description = "names of worker nodes for k8s cluster"
  type        = list(string)
  default     = ["worker", "worker", "worker"]
}

variable "image_type" {
  description = "AWS instance type"
  default     = "t2.medium"
}

# variable "vpc_cidr_range" {
#   type    = string
#   default = "10.0.0.0/16"
# }

# variable "public_subnets" {
#   type    = list(string)
#   default = ["10.0.0.0/24", "10.0.1.0/24"]
# }

# variable "database_subnets" {
#   type    = list(string)
#   default = ["10.0.8.0/24", "10.0.9.0/24"]
# }

# variable "public_key_path" {
  # default = "~/.ssh/id_rsa.pub"
# }
# 
# variable "key_name" {
  # default = "terraform-ansible-example-key"
# }
# 
# variable "tags" {
  # type = "map"
  # default = {
    # Repo = "https://github.com/opstodevops/terraform-ansible-k8s"
    # Terraform = true
  # }
# }

# variable "ssh_keys" {}

# variable "image" {
#     description = "The AWS AMI"
#     default = "ubuntu-18-04-x64"
# }

# variable "name" {
#     description = "The name of the AMI"
#     default = "nginx"
# }

# variable "region" {
#     description = "The region for the AMI"
#     default = "us-east-1"
# }

# variable "size" {
#     description = "The instance size"
#     default = "1gb"
# }

# variable "with_backups" {
#     description = "Boolean controlling if backups are made"
#     default = false
# }

# variable "with_monitoring" {
#     description = "Boolean controlling whether monitoring agent is installed"
#     default = false
# }

# variable "with_ipv6" {
#     description = "Boolean controlling if IPv6 is enabled"
#     default = false
# }

# variable "with_private_networking" {
#     description = "Boolean controlling if private networks are enabled"
#     default = false
# }

# variable "with_resize_disk" {
#     description = "Whether to increase the disk size when resizing a Droplet"
#     default = true
# }
