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

variable "subnet_1" {
    description = "CIDR of public subnet 1"
    default = "10.0.1.0/24"
}

variable "subnet_2" {
    description = "cidr of public subnet 2"
    default = "10.0.2.0/24"
}

variable "aws_sg_cidr_blocks_ingress_ssh" {
    description = "CIDR block for ssh access"
    default = "0.0.0.0/0"
}


variable "aws_sg_cidr_blocks_ingress_app" {
    description = "CIDR block for app ingress"
    default = "0.0.0.0/0"
}

variable "port_app" {
    default = "5000"
}

variable "key_path" {
    default = "~/terraform.pub"
}