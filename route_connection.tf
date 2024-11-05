# Create Route for Internet Access (PUBLIC Subnet) using IGW
resource "aws_route" "public_internet_access" {
  for_each               = var.igws
  route_table_id         = aws_route_table.public[each.value.rt_key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[each.key].id
  depends_on             = [aws_internet_gateway.this]
}

# Create Route for Internet Access (PRIVATE Subnet) using NATGW
resource "aws_route" "private_internet_access" {
  for_each               = var.natgws
  route_table_id         = aws_route_table.private[each.value.rt_key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
  depends_on             = [aws_nat_gateway.this]
}

resource "aws_route" "vpc_peering" {
  for_each                  = var.vpc_peering_connection_routes
  route_table_id            = (each.value.is_local) ? aws_route_table.private[each.value.rt_key].id : local.remote_states[each.value.remote_key].details.route_tables[each.value.rt_key]
  destination_cidr_block    = (each.value.is_local) ? local.remote_states[each.value.remote_key].details.vpcs[each.value.destination_cidr_block_vpc_key].cidr_block : aws_vpc.this[each.value.destination_cidr_block_vpc_key].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[each.value.vpc_peering_connection_id].id
}

