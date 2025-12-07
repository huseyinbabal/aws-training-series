output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = data.aws_vpc.default.id
}

# --- Node 1 Outputs ---
output "node_1_eip_address" {
  description = "Elastic IP of Node 1"
  value       = aws_eip.node_one_eip.public_ip
}

output "node_1_volume_id" {
  description = "ID of the extra EBS volume attached to Node 1"
  value       = aws_ebs_volume.node_one_vol.id
}

# --- Node 2 Outputs ---
output "node_2_public_ip" {
  description = "Public IP of Node 2 (Dynamic)"
  value       = aws_instance.node_two.public_ip
}
