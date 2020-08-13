variable "vpc_region" {
    default = "us-east-1"
}

variable "availability_zone" {
    default ={
        zone-1 = "us-east-1a"
        zone-2 = "us-east-1c"
        }
}

variable "vpc_cidr_block" {
    description = "CIDR block of vpc"
    default = "10.0.0.0/16"    
}

variable "vpc_public_subnet_cidr" {
    description = "CIDR of public subnet"
    default = {
        "us-east-1a" = "10.0.1.0/24"
        "us-east-1c" = "10.0.2.0/24"
    }
}

variable "aws_sg_cidr_blocks_ingress" {
    default = "0.0.0.0/0"
}
