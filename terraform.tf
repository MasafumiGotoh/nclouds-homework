terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}


provider "aws" {
    region                   = "us-east-1"
    shared_credentials_files  = ["/Users/Rem/.aws/credentials"]
    shared_config_files      = ["/Users/Rem/.aws/config"]
    profile                  = "AC"
}

#
# vpc
#

resource "aws_vpc" "andrewvpc" {
  cidr_block = "170.0.0.0/16"
  tags = {
    Name = "andrewvpc"
  }
}


#
# Public Subnets
#

resource "aws_subnet" "public1" {
    vpc_id    = aws_vpc.andrewvpc.id
    cidr_block = "170.0.1.0/24"

    tags = {
      Name = "ACPublicSubnet1"
    }
}

  resource "aws_subnet" "public2" {
      vpc_id    = aws_vpc.andrewvpc.id
      cidr_block = "170.0.2.0/24"

      tags = {
        Name = "ACPublicSubnet2"
      }
}

  resource "aws_subnet" "public3" {
        vpc_id    = aws_vpc.andrewvpc.id
        cidr_block = "170.0.3.0/24"

         tags = {
            Name = "ACPublicSubnet3"
      }
}

#
# Private Subnets
#
resource "aws_subnet" "private1" {
      vpc_id    = aws_vpc.andrewvpc.id
      cidr_block = "170.0.4.0/24"

        tags = {
          Name = "ACPrivateSubnet1"
        }
}

  resource "aws_subnet" "private2" {
        vpc_id    = aws_vpc.andrewvpc.id
        cidr_block = "170.0.5.0/24"

          tags = {
            Name = "ACPrivateSubnet2"
          }
}

 resource "aws_subnet" "private3" {
          vpc_id    = aws_vpc.andrewvpc.id
          cidr_block = "170.0.6.0/24"

          tags = {
            Name = "ACPrivateSubnet3"
            }
}

# Internet Gateway
 resource "aws_internet_gateway" "igw" {
          vpc_id = aws_vpc.andrewvpc.id

          tags = {
            Name = "andrewigw"
  }
}

# Elastic IP
 resource "aws_eip" "nat_eip" {
          vpc        = true
          depends_on = [aws_internet_gateway.igw]

          tags = {
            Name = "Elastic IP"
            }
  }


# Nat Gateway
 resource "aws_nat_gateway" "nat" {
        allocation_id = aws_eip.nat_eip.id
        subnet_id = aws_subnet.public1.id

        tags = {
            Name = "AC Nat Gateway"
  }
}

# Route Table Public
 resource "aws_route_table" "public" {
        vpc_id = aws_vpc.andrewvpc.id

        route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.igw.id
    }

        tags = {
        Name = "Public Route Table"
        }
    }

# Associate Public Subnet to Public Route Table
  resource "aws_route_table_association" "public" {
      subnet_id      = aws_subnet.public2.id
      route_table_id = aws_route_table.public.id
}


# Route Table Private
 resource "aws_route_table" "private" {
        vpc_id = aws_vpc.andrewvpc.id

        route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_nat_gateway.nat.id
        }

        tags = {
        Name = "Private Route Table"
        }
    }

# Associate Private Subnet to Private Route Table
  resource "aws_route_table_association" "private" {
      subnet_id      = aws_subnet.private1.id
      route_table_id = aws_route_table.private.id

      }
