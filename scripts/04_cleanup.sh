#!/bin/bash
export SVC_NAME="bgdsvc_tanjim26"

sudo pkill -u "$SVC_NAME" 2>/dev/null

sudo crontab -r -u "$SVC_NAME" 2>/dev/null
sudo rm -f "/etc/logrotate.d/$SVC_NAME"
sudo rm -f "/usr/local/bin/${SVC_NAME}_monitor.sh"
sudo rm -f "/usr/local/bin/${SVC_NAME}_cleanup_old_files.sh"

if mountpoint -q "/mnt/${SVC_NAME}_tmp"; then
    sudo umount "/mnt/${SVC_NAME}_tmp"
fi
sudo rmdir "/mnt/${SVC_NAME}_tmp" 2>/dev/null

sudo rm -rf "/var/log/$SVC_NAME"

sudo userdel -r "$SVC_NAME" 2>/dev/null

echo "Cleanup completed successfully."
