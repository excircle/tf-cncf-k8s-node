variable "application_name" {
  description = "Application Name"
  type = string
}

variable "createdby_tag" {
  description = "Tag for created by"
  type = string
  default = "Terraform"
}

variable "owner_tag" {
  description = "Tag for owner"
  type = string
  default = "Alexander Kalaj"
}

variable "hosts" {
  description = "Number of hosts to create"
  type = number
  default = 2
}

variable "ec2_key_name" {
  description = "EC2 Key Pair Name"
  type = string
  default = "minio-key"
}

variable "sshkey" {
  description = "SSH key to use with EC2 host"
  type        = string
}

variable "ec2_ami_image" {
  description = "EC2 AMI Image"
  type = string
}

variable "ec2_instance_type" {
  description = "AWS EC2 Instance Type"
  type = string
}

variable "make_private" {
  description = "Make the cluster private"
  type = bool
  default = false
}

variable "security_group_ids" {
  description = "Security Group IDs"
  type = list(string)
}


variable "aws_iam_role_name" {
  description = "AWS IAM Role Name"
  type = string
  default = "ec2_cli_role"
}

variable "aws_iam_policy_name" {
  description = "AWS IAM Policy Name"
  type = string
  default = "CLI-Policy"
}

variable "ec2_instance_profile_name" {
  description = "EC2 Instance Profile Name"
  type = string
  default = "ec2_instance_profile"
}

variable "root_block_device_size" {
  description = "Root Block Device Size"
  type = number
}

variable "num_disks" {
  description = "Number of disks to attach"
  type = number
  default = 1
}