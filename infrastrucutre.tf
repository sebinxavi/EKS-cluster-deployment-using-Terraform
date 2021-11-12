# ---------------------------------------------------
# Creating VPC
# ---------------------------------------------------
resource "aws_vpc" "myvpc" {
    
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
    
}


# ---------------------------------------------------
# Attaching InterNet Gateway
# ---------------------------------------------------

resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}


# ---------------------------------------------------
# Subnet myvpc-public-1
# ---------------------------------------------------

resource "aws_subnet" "public1" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public1_cidr
  availability_zone        = var.public1_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public1"
  }
}

# ---------------------------------------------------
# Subent myvpc-public-2
# ---------------------------------------------------

resource "aws_subnet" "public2" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public2_cidr
  availability_zone        = var.public2_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public2"
  }
}



# ---------------------------------------------------
# Subnet myvpc-public-3
# ---------------------------------------------------

resource "aws_subnet" "public3" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.public3_cidr
  availability_zone        = var.public3_az 
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public3"
  }
}

# ---------------------------------------------------
# Subnet myvpc-private-1
# ---------------------------------------------------

resource "aws_subnet" "private1" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private1_cidr
  availability_zone        = var.private1_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private1"
  }
}

# ---------------------------------------------------
# Subnet myvpc-private-2
# ---------------------------------------------------

resource "aws_subnet" "private2" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private2_cidr
  availability_zone        = var.private2_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private2"
  }
}



# ---------------------------------------------------
# Subnet myvpc-private-3
# ---------------------------------------------------

resource "aws_subnet" "private3" {
    
  vpc_id                   = aws_vpc.myvpc.id
  cidr_block               = var.private3_cidr
  availability_zone        = var.private3_az 
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private3"
  }
}


# ---------------------------------------------------
# Creating Elastic Ip
# ---------------------------------------------------

resource "aws_eip" "nat" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}


# ---------------------------------------------------
# Creating NAT gateway
# ---------------------------------------------------

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public3.id

  tags = {
    Name = "${var.project}-nat"
  }
}

# ---------------------------------------------------
# Public Route table
# ---------------------------------------------------

resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public"
  }
}


# ---------------------------------------------------
# Private Route table
# ---------------------------------------------------

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project}-private"
  }
}


# ---------------------------------------------------
# Route table Association public1 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}


# ---------------------------------------------------
# Route table Association public2 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------
# Route table Association public3 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}


# ---------------------------------------------------
# Route table Association private1 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}


# ---------------------------------------------------
# Route table Association private2 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------
# Route table Association private3 subnet
# ---------------------------------------------------

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
