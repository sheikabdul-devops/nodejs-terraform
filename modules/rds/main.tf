/*
  Create RDS MySQL Database
*/
resource "aws_security_group" "rds" {
    description = "Allow incoming database connections."

    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
        
    }

    ingress { # MySQL
        from_port = 3306
        to_port = 3306
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
        Name = "RDS mysql SG"
    }
}

resource "aws_db_parameter_group" "mysql_db_pg" {
name = "db-pgroup"
family = "mysql5.7"

tags = {
     Name = "db_para_group"
}

}


resource "aws_db_subnet_group" "db_subnet_group" {
name = "db_subnet_group"
subnet_ids = flatten([var.subnet_id])

tags = {
Name = "db_sub_data_group"
}

}

resource "aws_db_instance" "mysqldb" {
  name                    = "mysqldb"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = var.engine
  engine_version          = var.eng_version
  instance_class          = var.instance_type
  username                = var.rds_user
  password                = var.rds_pass
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = 0
  parameter_group_name    = aws_db_parameter_group.mysql_db_pg.name
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  final_snapshot_identifier = false
  
  tags = {
        Name = "RDS mysql"
    }

   depends_on = [var.vpc_id,aws_db_parameter_group.mysql_db_pg,aws_db_subnet_group.db_subnet_group]

}

output "rds_endpoint" {
  value = aws_db_instance.mysqldb.endpoint
}

output "rds_user" {
  value = aws_db_instance.mysqldb.username
}

output "rds_pass" {
  value = aws_db_instance.mysqldb.password
}


    
