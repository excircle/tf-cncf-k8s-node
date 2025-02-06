#!/bin/bash

# Global Variables
package_manager=${package_manager}
system_user=${system_user}
node_name=${node_name}
hosts=${hosts}
disks=${disks}

install_custom_dependencies() {
    # DEBIAN/APT BASED
    if [[ $1 == "apt" ]]; then
        sudo apt update
        sudo snap install yq
        sudo apt install -y chrony xfsprogs tree tzdata awscli curl wget vim net-tools jq unzip mlocate
    # REDHAT/DNF BASED
    elif [[ $1 == "dnf" ]]; then
        sudo dnf install -y chronyd xfsprogs tree tzdata awscli curl wget vim iproute jq unzip util-linux-user
    # GFYS
    else
        echo "Unsupported package manager: $1"
        exit 1
    fi
}


base_os_configuration() {
  # APT
  sudo hostnamectl set-hostname $node_name

  # If hostnamectl set-hostname command was successful, then write hostname to /etc/hostname-changed
  if [[ $? -eq 0 ]]; then
    echo "Hostname changed to ${node_name}"
    echo ${node_name} | sudo tee /etc/hostname-changed
  else
    echo "Failed to change hostname to ${node_name}"
  fi

  if [[ $package_manager == "apt" ]]; then
    # Set the timezone to America/Los_Angeles
    echo "Setting timezone to America/Los_Angeles..."
    sudo timedatectl set-timezone America/Los_Angeles
    
    # Enable and start chrony service
    echo "Enabling and starting chrony service..."
    sudo systemctl enable chrony
    sudo systemctl start chrony
  
  # DNF
  elif [[ $package_manager == "dnf" ]]; then
      # Set the timezone to America/Los_Angeles
      echo "Setting timezone to America/Los_Angeles..."
      sudo timedatectl set-timezone America/Los_Angeles
      
      # Enable and start chrony service
      echo "Enabling and starting chrony service..."
      sudo systemctl enable chronyd
      sudo systemctl start chronyd
  else
      echo -e "'package_manager' argument not supplied or is not in the following list ['apt', 'dnf']!\nPlease provide the package manager to use."
      exit 1
  fi

  # Verify the time and timezone settings
  echo "Verifying the time and timezone settings..."
  timedatectl

  # Check the status of chrony service
  echo "Checking the status of chrony service..."
  sudo chronyc tracking

  # Until loop that waits for all xvd disks to be attached
  echo "Starting disk wait loop"
  echo $disks
  for disk in ${disks}; do
    name=$(echo $disk | sed "s|\/| |g" | awk {'print $NF'})
    while [[ $(lsblk | grep $name | wc -l) == "0" ]]; do
      echo "$(date) - Disk $disk not found...waiting..."
      sleep 5
    done;
    echo "$(date) - Found $disk"
  done;
  echo "For loop completed"

  # Establish Disks
  idx=1
  for disk in ${disks}; do
    sudo mkfs.xfs /dev/$disk
    sudo mkdir -p /mnt/data$idx
    sudo mount /dev/$disk /mnt/data$idx
    sudo chown -R minio-user:minio-user /mnt/data$idx  sudo chown -R minio-user:minio-user /mnt/data$idx
    echo "/dev/$disk /mnt/data$idx xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
    ((idx++))
  done

  # Update /etc/hosts file with private ips
  for host in ${hosts}; do
    REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    PRIVATE_IP=$(aws ec2 describe-instances   --region $REGION   --filters "Name=tag:Name,Values=$host"   --query 'Reservations[*].Instances[*].PrivateIpAddress'   --output text)
    echo -e "$PRIVATE_IP $host" | sudo tee -a /etc/hosts
  done

  # Update SSH config to not ask for fingerprint verification
  sudo install -o ubuntu -g ubuntu -m 0600 /dev/null /home/ubuntu/.ssh/config
  cat > /home/ubuntu/.ssh/config <<EOF
Host *
  StrictHostKeyChecking no
EOF

}

############
### MAIN ###
############

main() {
  install_custom_dependencies $package_manager
  base_os_configuration $package_manager
}

main