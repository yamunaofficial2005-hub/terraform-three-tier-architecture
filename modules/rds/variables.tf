
variable "project_name" {
  type        = string
  description = "Project name"
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}

variable "db_security_group_id" {
  type        = string
  description = "Database security group ID"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
  default     = "appdb"
}

variable "db_username" {
  type        = string
  description = "Database master username"
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "engine_version" {
  type        = string
  description = "Supported MySQL engine version"
  default     = "8.0"
}
