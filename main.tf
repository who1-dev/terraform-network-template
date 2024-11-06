data "terraform_remote_state" "this" {
  for_each = var.remote_data_sources
  backend  = "s3"
  config = {
    bucket = each.value.bucket
    key    = each.value.key
    region = var.region
  }
}


locals {
  default_tags  = merge(var.default_tags, { "AppRole" : var.app_role, "Environment" : upper(var.env), "Project" : var.namespace })
  name_prefix   = upper("${var.namespace}-${var.env}")
  remote_states = { for k, v in data.terraform_remote_state.this : k => v.outputs }
  subnets       = merge(var.public_subnets, var.private_subnets)
}

# VPC Creation
resource "aws_vpc" "this" {
  for_each   = var.vpcs
  cidr_block = each.value.cidr_block
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
}

# IGW Creation
resource "aws_internet_gateway" "this" {
  for_each = var.igws
  vpc_id   = aws_vpc.this[each.value.vpc_key].id
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_vpc.this]
}

# SUBNET Creation
resource "aws_subnet" "this" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.this[each.value.vpc_key].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_vpc.this]
}

# PUBLIC - RT 
resource "aws_route_table" "public" {
  for_each = var.public_route_table
  vpc_id   = aws_vpc.this[each.value.vpc_key].id
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_vpc.this]
}

# PRIVATE - RT 
resource "aws_route_table" "private" {
  for_each = var.private_route_table
  vpc_id   = aws_vpc.this[each.value.vpc_key].id
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_vpc.this]
}


# PUBLIC - RT Association
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets
  route_table_id = aws_route_table.public[each.value.rt_key].id
  subnet_id      = aws_subnet.this[each.key].id
  depends_on     = [aws_route_table.public]
}

# PRIVATE - RT Association
resource "aws_route_table_association" "private" {
  for_each       = var.private_subnets
  route_table_id = aws_route_table.private[each.value.rt_key].id
  subnet_id      = aws_subnet.this[each.key].id
  depends_on     = [aws_route_table.private]
}


# EIP Creation
resource "aws_eip" "this" {
  for_each = var.eips
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
}

# NAT GATEWAY Creation
resource "aws_nat_gateway" "this" {
  for_each      = var.natgws
  allocation_id = aws_eip.this[each.value.eip_key].id
  subnet_id     = aws_subnet.this[each.value.pub_sub_key].id
  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_vpc_peering_connection" "this" {
  for_each    = var.vpc_peering_connections
  vpc_id      = aws_vpc.this[each.value.vpc_key].id
  peer_vpc_id = (each.value.is_local) ? aws_vpc.this[each.value.vpc_key].id : local.remote_states[each.value.remote_key].details.vpcs[each.value.peer_vpc_id].id
  auto_accept = true

  tags = merge(local.default_tags, {
    Name = upper("${local.name_prefix}-${each.value.name}")
  })
  depends_on = [aws_vpc.this]
}
