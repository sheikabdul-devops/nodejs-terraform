provider "aws" {
    access_key = var.access_key 
    secret_key = var.secret_key 
    region     = var.region 
}

module "my_vpc" {
    source = "../modules/vpc"
    vpc_cidr              = var.vpc_cidr 
    main_subnet_cidr      = var.main_subnet 
    secondary_subnet_cidr = var.second_subnet 
    terraform_ip          = var.terraform_ip
}

module "my_rds" {
    source = "../modules/rds"
    vpc_id              = module.my_vpc.vpc_id
    vpc_cidr            = module.my_vpc.vpc_cidr 
    subnet_id           = [module.my_vpc.subnet_ids]
    instance_type       = var.db_instance_type 
    rds_user            = var.db_user
    rds_pass            = var.db_pass
    engine              = "mysql"
    eng_version         = "5.7"
    terraform_ip        = module.my_vpc.terraform_ip
    
}

module "my_ec2" {
    source = "../modules/ec2"
    id_count            = var.instance_count
    vpc_id              = module.my_vpc.vpc_id
    subnet_ids          = flatten([module.my_vpc.subnet_ids])
    aws_key_name        = var.key_name 
    aws_key_path        = var.key_path 
    rds_endpoint        = module.my_rds.rds_endpoint
    rds_user            = module.my_rds.rds_user
    rds_pass            = module.my_rds.rds_pass
    ssh_user            = var.ssh_user 
    sourcedir           = var.source_code_dir 
    destdir             = var.dest_dir 
    vpc_cidr            = module.my_vpc.vpc_cidr
    terraform_ip        = module.my_vpc.terraform_ip
    instance_type       = var.ec2_instance_type

}

module "my_elb" {
    source = "../modules/elb"
    instances           = flatten([module.my_ec2.*.instance_ids])
    subnet_ids          = flatten([module.my_vpc.subnet_ids])
    vpc_id              = module.my_vpc.vpc_id
    terraform_ip        = module.my_vpc.terraform_ip
}

