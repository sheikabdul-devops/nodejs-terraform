# Create a new load balancer

resource "aws_security_group" "elb" {
    description = "Allow incoming database connections."

    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.terraform_ip]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    vpc_id = var.vpc_id

    tags = {
        Name = "ELB SG"
    }
}



resource "aws_elb" "myapp" {
  name               = "myapp-elb"
  
  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/devices"
    interval            = 30
  }
 
  instances             = flatten([var.instances])
  subnets               = flatten([var.subnet_ids])
  security_groups       = [aws_security_group.elb.id]
  
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "myapp-elb"
  }

  depends_on = [var.instances]
}

output "elb_id" {
  value = [aws_elb.myapp.id]
}

output "elb_address" {
  value = aws_elb.myapp.public_dns
}
