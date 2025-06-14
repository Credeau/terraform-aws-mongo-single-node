# ----------------------------------------------
# Deployment Environment Related Variables
# ----------------------------------------------
variable "application" {
  type        = string
  description = "Application name for which this database is provisioned"
  default     = "dummy"
}

variable "environment" {
  type        = string
  description = "Provisioning environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod", "uat"], var.environment)
    error_message = "Environment must be one of: dev, prod, or uat."
  }
}

variable "region" {
  type        = string
  description = "AWS operational region"
  default     = "ap-south-1"
}

variable "stack_owner" {
  type        = string
  description = "owner of the stack"
  default     = "tech@credeau.com"
}

variable "stack_team" {
  type        = string
  description = "team of the stack"
  default     = "devops"
}

variable "organization" {
  type        = string
  description = "organization name"
  default     = "credeau"
}

variable "alert_email_recipients" {
  type        = list(string)
  description = "email recipients for sns alerts"
  default     = []
}

# ----------------------------------------------
# Network Related Variables
# ----------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID of the VPC to provision the resources in"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch the server network"
}

variable "mongodb_whitelisted_cidrs" {
  type        = list(string)
  description = "List of CIDR block IP ranges to allow connecting with MongoDB (port: 27017)"
  default     = []
}

variable "mongodb_whitelisted_sg_ids" {
  type        = list(string)
  description = "List of Security Group IDs to allow connecting with MongoDB (port: 27017)"
  default     = []
}

variable "ssh_whitelisted_cidrs" {
  type        = list(string)
  description = "List of CIDR block IP ranges to allow SSH on MongoDB instance (port: 22)"
  default     = []
}

variable "ssh_whitelisted_sg_ids" {
  type        = list(string)
  description = "List of Security Group IDs to allow SSH on MongoDB instance (port: 22)"
  default     = []
}

# ----------------------------------------------
# Server Related Variables
# ----------------------------------------------

variable "instance_type" {
  type        = string
  description = "Type of instance to provision for mongo"
  default     = "t3a.medium"
}

variable "key_pair_name" {
  type        = string
  description = "SSH key pair to use for system access"
}

variable "cpu_threshold" {
  type        = number
  description = "CPU threshold for scaling"
  default     = 60
}


variable "memory_threshold" {
  type        = number
  description = "Memory threshold for scaling"
  default     = 60
}

variable "disk_threshold" {
  type        = number
  description = "Disk threshold for scaling"
  default     = 70
}

# ----------------------------------------------
# DB & Storage Related Variables
# ----------------------------------------------

variable "mongo_user_name" {
  type        = string
  description = "value"
  default     = "mongo"
  sensitive   = true
}

variable "mongo_password" {
  type        = string
  description = "value"
  sensitive   = true
}

variable "mongo_default_storage_compression_type" {
  type        = string
  description = "Default storage compression type"
  default     = "zstd"

  validation {
    condition     = contains(["none", "snappy", "zlib", "zstd"], var.mongo_default_storage_compression_type)
    error_message = "Compression type must be one of: none, snappy, zlib, zstd."
  }
}

variable "mongo_port" {
  type        = number
  description = "Port number to bind with mongo db"
  default     = 27017
}

variable "disk_size" {
  type        = number
  description = "Size in GBs to provision as database storage"
  default     = 50

  validation {
    condition     = var.disk_size >= 1 && var.disk_size <= 16384
    error_message = "The disk_size value for a GP3 disk must be between 1 and 16384 GBs."
  }
}

variable "disk_iops" {
  type        = number
  description = "IOPS to provision in database storage"
  default     = 3000

  validation {
    condition     = var.disk_iops >= 3000 && var.disk_iops <= 16000
    error_message = "The disk_iops value for a GP3 disk must be between 3000 and 16000."
  }
}

variable "encrypt_storage" {
  type        = bool
  description = "Enable/Disable the encryption of database storage"
  default     = false
}

variable "base_snapshot_id" {
  type        = string
  description = "ID of an existing EBS snapshot to create the volume from. If not specified, an empty volume will be created."
  default     = null
}

variable "mongo_data_location" {
  type        = string
  description = "Directory location where MOngoDB will store its data"
  default     = "/var/lib/mongodb"
}
