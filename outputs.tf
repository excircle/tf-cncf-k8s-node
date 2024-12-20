output "locals_data" {
    value = {
        tag = {
        Name      = null
        CreatedBy = var.createdby_tag
        Owner     = var.owner_tag
        Purpose   = null
        }
        host_names = [for v in range(1, var.hosts+1): "${var.application_name}-${v}"]
        disks = [
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z"
        ]
        nodes = { for v in local.host_names : v => {
            disknames = slice(local.disks, 0, var.num_disks) 
        }
        }
    }
}

output "local-disks" {
  value       = local.disks
}

output "disk-names" {
  value       = local.disk_names
}


output "subnets" {
  value     = var.subnets
}

output "ec2s" {
  value   = aws_instance.minio_host
}

output "minio_host_info" {
  value = {
    for k, v in aws_instance.minio_host : k => {
      id                 = v.id
      availability_zone  = v.availability_zone
    }
  }
}

output "ebs_storage_volume_size" {
  value = var.ebs_storage_volume_size
}
