variable "amis" {
    default = "ami-0a13d44dccf1f5cf6" 
}
variable "vpc_id" {}
variable "id_count" {}
variable "aws_key_name" {}
variable "aws_key_path" {}
variable "subnet_ids" {
    type = list(string)
}
variable "rds_endpoint" {}
variable "rds_user" {}
variable "rds_pass" {}

variable "ssh_user" {} 
variable "sourcedir" {} 
variable "destdir" {} 
variable "terraform_ip" {}
variable "vpc_cidr" {}
variable "instance_type"{}