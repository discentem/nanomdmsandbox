output "arn" {
  value = aws_vpc.main.arn
}

output "id" {
  value = aws_vpc.main.id
}

output "instance_tenancy" {
  value = aws_vpc.main.instance_tenancy
}

output "enable_dns_support" {
  value = aws_vpc.main.enable_dns_support
}

output "enable_dns_hostnames" {
  value = aws_vpc.main.enable_dns_hostnames
}

output "enable_classiclink" {
  value = aws_vpc.main.enable_classiclink
}

output "main_route_table_id" {
  value = aws_vpc.main.main_route_table_id
}

output "default_network_acl_id" {
  value = aws_vpc.main.default_network_acl_id
}

output "default_network_acl_id" {
  value = aws_vpc.main.default_network_acl_id
}

output "default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}

output "default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
}

output "ipv6_association_id" {
  value = aws_vpc.main.ipv6_association_id
}

output "ipv6_cidr_block_network_border_group" {
  value = aws_vpc.main.ipv6_cidr_block_network_border_group
}

output "owner_id" {
  value = aws_vpc.main.owner_id
}
