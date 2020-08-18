provider "aws"{
    profile = "default"
    region = var.vpc_region
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_1
    availability_zone = var.availability_zone["zone-1"]
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_2
    availability_zone = var.availability_zone["zone-2"]
}

resource "aws_internet_gateway"  "gateway"{
    vpc_id = aws_vpc.main.id


    tags = {
        Name = "main"
    }
}


resource "aws_route_table" "vpc_public_sn" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
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
        cidr_blocks = [var.aws_sg_cidr_blocks_ingress_ssh]  
    }

    ingress {
        description = "App"
        from_port = var.port_app
        to_port =  var.port_app
        protocol = "tcp"
        cidr_blocks = [var.aws_sg_cidr_blocks_ingress_app]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_launch_configuration" "config_ec2" {
    image_id = "ami-0bcc094591f354be2"  
    instance_type = "t2.micro"
    security_groups = [aws_security_group.vpc_main_sg.id]
    associate_public_ip_address = true

    user_data = <<-EOF
                #!/bin/bash
                apt update
                apt install software-properties-common
                apt-get upgrade -y
                apt-add-repository --yes --update ppa:ansible/ansible
                apt install python3.8 --yes
                apt install git --yes
                apt install ansible --yes
                mkdir app
                git clone git://github.com/CEBS13/node-ansible
                cd node-ansible
                ansible-playbook node-playbook.yml
                EOF

    lifecycle {
        create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "main_asg" {
    launch_configuration = aws_launch_configuration.config_ec2.name
    vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 4

    tag {
        key = "Name"
        value = "app-asg"
        propagate_at_launch = true
    }
}

// load balancer
resource "aws_lb" "main_lb" {
    name = "app-lb"
    load_balancer_type = "application"
    subnets = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}


resource "aws_security_group" "alb" {
    name = "chatApp-sg-alb"
    vpc_id = aws_vpc.main.id
    ingress{
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_lb_target_group" "asg" {
    name     = "chatApp-asg"
    port     = var.port_app 
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = 200
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

}


resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100
    
    condition {
        path_pattern {
            values = [ "*"]
        }
    }

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

output "alb_dns_name" {
    value        = aws_lb.main_lb.dns_name
    description  = "The domain name of the load balancer"

}





