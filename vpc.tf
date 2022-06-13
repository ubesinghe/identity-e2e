resource "aws_vpc" "e2e-vpc" {
  cidr_block              = var.cidr_vpc
  enable_dns_support      = true
  enable_dns_hostnames    = true
  tags = {
    Name = "e2e-vpc"
  }
}

resource "aws_subnet" "e2e_frontend_a" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  cidr_block              = var.cidr_subnet_public_a
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_a
  tags = {
    Name = "e2e_frontend_a"
  }
}

resource "aws_subnet" "e2e_frontend_b" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  cidr_block              = var.cidr_subnet_public_b
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_b
  tags = {
    Name = "e2e_frontend_b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "frontend-rtb-a" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "frontend-rtb-a"
  }
}

resource "aws_route_table_association" "rta_subnet_frontend_a" {
  subnet_id              = aws_subnet.e2e_frontend_a.id
  route_table_id         = aws_route_table.frontend-rtb-a.id
}

resource "aws_route_table" "frontend-rtb-b" {
  vpc_id                 = aws_vpc.e2e-vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id           = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rta_subnet_frontend_a"
  }
}

resource "aws_route_table_association" "rta_subnet_frontend_b" {
  subnet_id              = aws_subnet.e2e_frontend_b.id
  route_table_id         = aws_route_table.frontend-rtb-b.id
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "e2e_nat_eip_a" {
  vpc = true
}


resource "aws_nat_gateway" "e2e_nat_a" {
  connectivity_type      = "public"
  subnet_id              = aws_subnet.e2e_frontend_a.id
  allocation_id          = aws_eip.e2e_nat_eip_a.id

  tags = {
    Name        = "nat"
    Name = "e2e_nat_a"
  }

}
# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "e2e_nat_eip_b" {
  vpc = true
}

resource "aws_nat_gateway" "e2e_nat_b" {
  connectivity_type      = "public"
  subnet_id              = aws_subnet.e2e_frontend_b.id
  allocation_id          = aws_eip.e2e_nat_eip_b.id

  tags = {
    Name        = "nat"
    Name = "e2e_nat_b"
  }

}

resource "aws_subnet" "e2e_backend_a" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  cidr_block              = var.cidr_subnet_private_a
  map_public_ip_on_launch = "false"
 availability_zone        = var.availability_zone_a
  tags = {
    Name = "e2e-backend_a"
  }
}

resource "aws_subnet" "e2e_backend_b" {
  vpc_id                  = aws_vpc.e2e-vpc.id
  cidr_block              = var.cidr_subnet_private_b
  map_public_ip_on_launch = "false"
  availability_zone       = var.availability_zone_b
  tags = {
    Name = "e2e-backend_b"
  }
}


resource "aws_route_table" "backend-rtb_a" {
  vpc_id                  = aws_vpc.e2e-vpc.id

  route {
      cidr_block          = "0.0.0.0/0"
      nat_gateway_id      = aws_nat_gateway.e2e_nat_a.id
    }
  

  tags = {
    Name = "backend-rtb_a"
  }
}

resource "aws_route_table" "backend-rtb_b" {
  vpc_id                    = aws_vpc.e2e-vpc.id

  route {
      cidr_block            = "0.0.0.0/0"
      nat_gateway_id        = aws_nat_gateway.e2e_nat_b.id
    }
  

   tags = {
    Name = "backend-rtb_b"
  }
}

resource "aws_route_table_association" "rta_subnet_private-a" {
  subnet_id                 = aws_subnet.e2e_backend_a.id
  route_table_id            = aws_route_table.backend-rtb_a.id
}

resource "aws_route_table_association" "rta_subnet_private-b" {
  subnet_id                 = aws_subnet.e2e_backend_b.id
  route_table_id            = aws_route_table.backend-rtb_b.id
}




