# Create EC2 Instances 

resource "aws_security_group" "web-sg" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = [var.terraform_ip]
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.terraform_ip]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = [var.terraform_ip]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = var.vpc_id

    tags = {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web" {
  
  count            = var.id_count
  ami              = var.amis
  instance_type    = var.instance_type
  key_name         = var.aws_key_name
  subnet_id        = var.subnet_ids[count.index % 2]
  security_groups  = [aws_security_group.web-sg.id] 

  connection {
    type = "ssh"
    user = var.ssh_user 
    private_key = file("${var.aws_key_path}")
    host  = self.public_ip
  }
  
  provisioner "file" {
    source      = var.sourcedir 
    destination = var.destdir
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y mysql",
      "cd ~",
      "curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -",
      "sudo yum install -y nodejs",
      "sudo npm install -g forever",
      "chmod +x ${var.destdir}/scripts/bootstrap.sh",
      "${var.destdir}/scripts/bootstrap.sh ${var.rds_endpoint} ${var.rds_user} ${var.rds_pass} ${var.destdir} &> ./script.log",
      "cd ${var.destdir}/scripts/myfirstapp/",
      "forever start server.js",
    ]

  }

  tags = {
    Name = "WebServer-${count.index}"
  }

  depends_on = [var.rds_endpoint]

}

output "instance_ids" {
  value = [aws_instance.web.*.id]
}

