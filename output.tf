output "details" {
  value = {
    vpcs         = { for k, v in aws_vpc.this : k => { id = v.id, cidr_block = v.cidr_block } }
    subnets      = { for k, v in aws_subnet.this : k => v.id }
    route_tables = { for k, v in merge(aws_route_table.public, aws_route_table.private) : k => v.id }
  }
}