provider "aws"{
    profile = "default"
    region = var.vpc_region
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.vpc_public_subnet_cidr
    availability_zone = var.availability_zone["zone-1"]
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.vpc_public_subnet_cidr
    availability_zone = var.availability_zone["zone-2"]
}

resource "aws_inernet_gateway"  "gateway"{
    vpc_id = aws_vpc.main.id


    tags = {
        Name = "main"
    }
}


resource "aws_route_table" "vpc_public_sn" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_inernet_gateway.gateway.id
    }
}

resource "aws_route_table_association" "route_table_sn_1" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.vpc_public_sn.id
}

resource "aws_route_table_association" "route_table_sn_2"{
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.vpc_public_sn.id
}

resource "aws_security_group" "vpc_main_sg" {
    name = "public_access_sg"
    description = "give public access security group"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "SSH Access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.aws_sgr_cidr_blocks_ingress]  
    }

    ingress{
        description = "HTTP"
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = [var.aws_sgr_cidr_blocks_ingress]
    }

    ingress {
        description = "App"
        from_port = 5000
        to_port =  5000
        protocol = "tcp"
        cidr_block = [var.aws_sgr_cidr_blocks_ingress]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.aws_sgr_cidr_blocks_ingress]
    }

}




output "vpc_id" {
    value  = aws_vpc.main.id
}

output "vpc_cidr_block" {
    value  = aws_vpc.main.cidr_block
}

output "subnet_1_cidr_block" {
    value  = aws_subnet.subnet_1.cidr_block
}

output "subnet_1_az" {
    value  = aws_subnet.subnet_1.availability_zone
}

output "subnet_2_cidr_block" {
    value  = aws_subnet.subnet_2.cidr_block
}

output "subnet_2_az" {
    value  = aws_subnet.subnet_2.availability_zone
}







