#VPC principal
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = { 
        Name = "Marco-ch-vpc" 
    }
}

#Internet Gateway para la VPC
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = { 
        Name = "Marco-ch-igw" 
    }
}

#Subnets públicas 
resource "aws_subnet" "public" {
    for_each = { for i, az in var.azs : az => az }
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.vpc_cidr, 4, index(var.azs, each.key))
    map_public_ip_on_launch = true
    availability_zone = each.key
    tags = {
        Name = "Marco-ch-public-${each.key}"
    }
}
#Subnets privadas
resource "aws_subnet" "private" {
    for_each = { for i, az in var.azs : az => az }
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.vpc_cidr, 4, index(var.azs, each.key) + 8)
    availability_zone = each.key
    tags = {
        Name = "Marco-ch-private-${each.key}"
    }
}  

#Tabla de rutas públicas
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Marco-ch-rt-public"
    }
}
#Asociación de las subnets públicas con la tabla de rutas públicas
resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id   
}


# # Elastic IP para NAT Gateway
# resource "aws_eip" "nat" {
#   tags = {
#     Name = "Marco-ch-nat-eip"
#   }
# }

# NAT Gateway en subnet pública (usando la primera AZ)
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[var.azs[0]].id
#   tags = {
#     Name = "Marco-ch-nat-gateway"
#   }
# }

# # Tabla de rutas privadas
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   # Ruta 0.0.0.0/0 hacia NAT Gateway
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "Marco-ch-rt-private"
#   }
# }

# # Asociar todas las subnets privadas con la tabla de rutas privadas
# resource "aws_route_table_association" "private" {
#   for_each = aws_subnet.private
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.private.id
# }
