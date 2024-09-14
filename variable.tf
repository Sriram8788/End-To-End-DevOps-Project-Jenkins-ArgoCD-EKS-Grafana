variable "region" {
  default = "us-east-1"
}
variable "vpc_name" {
    default = "VIP_vpc"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "avilability_zone" {
    type = list(string)
    default = [ "eu-west-1a", "eu-west-1b", "eu-west-1c" ]
}
variable "public_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}