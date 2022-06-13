variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnet_public_a" {
  description = "Frontend CIDR block for the subnet_a"
  default     = "10.1.0.0/24"
}
variable "cidr_subnet_public_b" {
  description = "Frontend CIDR block for the subnet_b"
  default     = "10.1.1.0/24"
}

variable "cidr_subnet_private_a" {
  description = "Backend CIDR block for the subnet_a"
  default     = "10.1.3.0/24"
}

variable "cidr_subnet_private_b" {
  description = "Backend CIDR block for the subnet_a"
  default     = "10.1.4.0/24"
}

variable "availability_zone_a" {
  description = "availability zone to create subnet_a"
  default     = "eu-west-2a"
}
variable "availability_zone_b" {
  description = "availability zone to create subnet_b"
  default     = "eu-west-2b"
}
variable "public_key_path" {
  description = "Public key path"
  default     = "~/.ssh/id_rsa.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default     = "ami-0d729d2846a86a9e7"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default     = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  type        = string
  default     = "e2e-dev"
}

variable "availability_zones" {
  default     = "eu-west-2a,eu-west-2b"
  description = "List of availability zones, use AWS CLI to find your "
}

