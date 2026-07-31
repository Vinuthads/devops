variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}


variable "instance_type" {
  description = "Free tier EC2 instance type"
  type        = string
  default     = "t3.micro"
}


variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-01a00762f46d584a1"
}


variable "key_name" {
  description = "AWS EC2 Key Pair name"
  type        = string
  default     = "server"
}


variable "project_name" {
  default = "devops-project"
}
