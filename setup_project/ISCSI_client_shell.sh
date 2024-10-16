#!/bin/bash

# Variables
TARGET_IP="192.168.138.100"
TARGET_PORT="3260"
TARGET_IQN="iqn.2024-10.com.example:target1"
MOUNT_POINT="/mnt/mydisk"
DEVICE_PATH="/dev/sdb"   # This will be the iSCSI disk path after login
FILESYSTEM_TYPE="xfs"

# Install necessary packages
echo "Installing iscsi-initiator-utils..."
sudo dnf install -y iscsi-initiator-utils

# Discover the iSCSI targets
echo "Discovering iSCSI targets from ${TARGET_IP}..."
sudo iscsiadm --mode discovery --type sendtargets --portal ${TARGET_IP}

# Login to the iSCSI target
echo "Logging in to iSCSI target ${TARGET_IQN}..."
sudo iscsiadm --mode node --targetname ${TARGET_IQN} --portal ${TARGET_IP}:${TARGET_PORT} --login

# Check if login was successful
if [ $? -eq 0 ]; then
  echo "iSCSI login successful!"
  
  # Check if the block device is present
  lsblk | grep ${DEVICE_PATH}
  
  if [ $? -eq 0 ]; then
    # Create a filesystem on the iSCSI disk
    echo "Creating ${FILESYSTEM_TYPE} filesystem on ${DEVICE_PATH}..."
    sudo mkfs.${FILESYSTEM_TYPE} ${DEVICE_PATH}
    
    # Create mount point and mount the device
    echo "Mounting ${DEVICE_PATH} to ${MOUNT_POINT}..."
    sudo mkdir -p ${MOUNT_POINT}
    sudo mount ${DEVICE_PATH} ${MOUNT_POINT}
    
    # Verify the disk is mounted
    df -h | grep ${MOUNT_POINT}
    
    echo "Disk successfully mounted on ${MOUNT_POINT}."
  else
    echo "iSCSI disk not found. Please verify the connection."
  fi
else
  echo "iSCSI login failed. Checking for authorization issues..."

  # Get the client IQN
  CLIENT_IQN=$(cat /etc/iscsi/initiatorname.iscsi | grep InitiatorName | cut -d= -f2)
  echo "Client IQN: ${CLIENT_IQN}"

  echo "Please verify that the iSCSI target ACL contains the correct client IQN: ${CLIENT_IQN}"
fi
