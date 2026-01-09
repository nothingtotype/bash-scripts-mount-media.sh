#!/bin/bash

# Configuration
SERVER_IP="192.168.100.70"

# 1. Install nfs-utils if not present
if ! rpm -q nfs-utils &>/dev/null; then
    echo "Installing nfs-utils..."
    sudo dnf install -y nfs-utils
fi

# 2. Scan for available exports
echo "Scanning for NFS shares on $SERVER_IP..."
EXPORT_LINE=$(showmount -e $SERVER_IP | grep '^/' | head -n 1)

if [ -z "$EXPORT_LINE" ]; then
    echo "Error: No NFS exports found on $SERVER_IP."
    exit 1
fi

# Extract the share path (first column)
REMOTE_PATH=$(echo $EXPORT_LINE | awk '{print $1}')
echo "Found share: $REMOTE_PATH"

# 3. Create a local directory with the same path
echo "Creating local directory: $REMOTE_PATH"
sudo mkdir -p "$REMOTE_PATH"

# 4. Mount the NFS share
echo "Mounting $SERVER_IP:$REMOTE_PATH to $REMOTE_PATH..."
sudo mount -t nfs "$SERVER_IP:$REMOTE_PATH" "$REMOTE_PATH"

# 5. Change permissions to allow all access
echo "Setting permissions to 777..."
sudo chmod 777 "$REMOTE_PATH"


# Verify mount
if mountpoint -q "$REMOTE_PATH"; then
    echo "Successfully mounted $REMOTE_PATH"
else
    echo "Failed to mount the share."
    exit 1
fi
