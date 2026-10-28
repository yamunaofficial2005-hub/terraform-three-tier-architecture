
variable "project_name" {
  type    = string
  default = "three-tier"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}