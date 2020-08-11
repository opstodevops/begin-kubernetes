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
  default = "./kubernetes-key.pem"
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
