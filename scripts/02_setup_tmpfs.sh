#!/bin/bash
export SVC_NAME="bgdsvc_tanjim26"
MOUNT_DIR="/mnt/${SVC_NAME}_tmp"

if mountpoint -q "$MOUNT_DIR"; then
    echo "tmpfs is already mounted at $MOUNT_DIR"
else
    sudo mkdir -p "$MOUNT_DIR"
    sudo mount -t tmpfs -o size=256M tmpfs "$MOUNT_DIR"
    sudo chown "$SVC_NAME:$SVC_NAME" "$MOUNT_DIR"
    echo "tmpfs successfully mounted at $MOUNT_DIR"
fi
