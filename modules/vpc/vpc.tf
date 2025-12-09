locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ----------------------------------------------------
# VPC
# ----------------------------------------------------
resource "aws_vpc" "verdethos_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.name_prefix}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ----------------------------------------------------
# SUBNETS (PUBLIC + PRIVATE)
# ----------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.verdethos_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.verdethos_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
  }
}

# ----------------------------------------------------
# INTERNET GATEWAY
# ----------------------------------------------------
resource "aws_internet_gateway" "verdethos_igw" {
  vpc_id = aws_vpc.verdethos_vpc.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# ----------------------------------------------------
# PUBLIC ROUTE TABLE
# ----------------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.verdethos_vpc.id

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.verdethos_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# ----------------------------------------------------
# PRIVATE ROUTES + NAT (OPTIONAL)
# ----------------------------------------------------
resource "aws_eip" "nat" {
  count = var.create_nat ? var.az_count : 0
  vpc   = true

  tags = {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat ? var.az_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${local.name_prefix}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.verdethos_igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.verdethos_vpc.id

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route" "private_default_route" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet }

  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = length(aws_nat_gateway.nat) > 0 ? aws_nat_gateway.nat[each.key].id : null
}

resource "aws_route_table_association" "private_assoc" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
