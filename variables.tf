variable "prefix" {
  default = "phonebook"
}

# AWS
variable "region" {
  default = "us-east-1"
}

# GitHub
variable "github_token_path" {
  default = "~/Documents/DevOps/GitHub/"
}

variable "github_token_filename" {
  default = "github_token"
}

variable "github_repo_name" {
  description = "Should match with 'phonebook-app.py' line #13"
  default     = "Terraform-AWS-ELB-Auto-Scaling-MySQL-Phonebook-App"
}

variable "github_repo_branch" {
  default = "main"
}

# DB Server
variable "db_name" {
  description = "Should match with 'phonebook-app.py' line #20"
  default     = "phonebook"
}

variable "db_username" {
  description = "Should match with 'phonebook-app.py' line #20"
  default     = "phonebook"
}

variable "db_password" {
  description = "Should match with 'phonebook-app.py' line #21"
  default     = "Password1234"
}

# SSH
variable "ssh_key_name" {
  default = "nvirginia"
}

variable "ssh_private_key_path" {
  default = "~/Documents/DevOps/AWS/"
}