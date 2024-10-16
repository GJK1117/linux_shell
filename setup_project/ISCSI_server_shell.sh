#!/bin/bash

# Variables
TARGET_IQN="iqn.2024-10.com.example:target1"
INITIATOR_IQN="iqn.2024-10.com.client:initiator"
DEVICE_PATH="/dev/md0"   # Update this to the correct block device path
PORTAL_IP="0.0.0.0"
PORTAL_PORT="3260"

# Install necessary packages
echo "Installing targetcli..."
sudo dnf install -y targetcli

# Enable and start the target service
echo "Enabling and starting target service..."
sudo systemctl enable --now target

# Configure iSCSI target
echo "Configuring iSCSI target..."
sudo targetcli <<EOF
/backstores/block create disk1 ${DEVICE_PATH}
/iscsi create ${TARGET_IQN}
/iscsi/${TARGET_IQN}/tpg1/luns create /backstores/block/disk1
/iscsi/${TARGET_IQN}/tpg1/acls create ${INITIATOR_IQN}
/iscsi/${TARGET_IQN}/tpg1/portals create ${PORTAL_IP} ${PORTAL_PORT}
saveconfig
exit
EOF

# Configure firewall to allow iSCSI traffic
echo "Configuring firewall..."
sudo firewall-cmd --add-port=${PORTAL_PORT}/tcp --permanent
sudo firewall-cmd --reload

echo "iSCSI server setup is complete!"
