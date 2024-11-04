locals {
  // Universal AWS Tag
  tag = {
    Name      = null
    CreatedBy = var.createdby_tag
    Owner     = var.owner_tag
    Purpose   = null
  }
  // Host names
  host_names = [for i in range(var.hosts) : "${var.application_name}-${i + 1}"]
  // Disks
  
}