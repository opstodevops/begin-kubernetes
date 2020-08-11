##################################################################################
# OUTPUT
##################################################################################

output "master_node_public_ip" {
  value = aws_instance.master_node.*.public_ip
  # value = [for linux in aws_instance.nix_servers : linux.public_ip]
}

output "worker_nodes_public_ip" {
  value = aws_instance.worker_nodes.*.public_ip
  # value = [for linux in aws_instance.nix_servers : linux.public_ip]
}

output "master_node_ssh" {
  value = [for master in aws_instance.master_node : "ssh ${local.vm_user}@${master.public_ip}"]
}

output "worker_node_ssh" {
  value = [for worker in aws_instance.worker_nodes : "ssh ${local.vm_user}@${worker.public_ip}"]
}

# output "ec2key_name" {
#   value = aws_key_pair.ec2key.key_name
# }

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

# output "db_subnet_group" {
#   value = module.vpc.database_subnet_group
# }

# output "public_subnets" {
#   value = module.vpc.public_subnets
# }