variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application Name"
  default     = "spring-react-crud"
}

variable "vpc_id" {
  description = "VPC ID (Optional - if empty, uses default VPC)"
  default     = ""
}
