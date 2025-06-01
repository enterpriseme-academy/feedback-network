variable "app_name" {
  type        = string
  description = "Name for the vpc"
  default     = "feedback-app-vpc"
}

variable "app_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "external_name" {
  type        = string
  description = "Name for the vpc for external access"
  default     = "external-vpc"
}

variable "external_cidr" {
  type        = string
  description = "CIDR block for the external VPC"
  default     = "10.0.0.0/16"
}

variable "internal_name" {
  type        = string
  description = "Name for the vpc for internal access"
  default     = "internal-vpc"
}

variable "internal_cidr" {
  type        = string
  description = "CIDR block for the internal VPC"
  default     = "10.0.0.0/16"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the VPC and resources"
  default     = {}
}

variable "from_port" {
  type        = number
  description = "Starting port for the security group ingress rule"
  default     = 5000
}

variable "to_port" {
  type        = number
  description = "Ending port for the security group ingress rule"
  default     = 5000
}

variable "external_enabled" {
  type        = bool
  description = "Flag to create External VPC."
  default     = true
}

variable "internal_enabled" {
  type        = bool
  description = "Flag to create Internal VPC."
  default     = true

}