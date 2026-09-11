#!/bin/bash
export SVC_NAME="bgdsvc_tanjim26"
MOUNT_DIR="/mnt/${SVC_NAME}_tmp"

case "$1" in
  --disk)
    echo "Filling tmpfs storage..."
    for i in $(seq 1 25); do
      sudo dd if=/dev/urandom of="$MOUNT_DIR/file_$i.dat" bs=10M count=1 status=none 2>/dev/null
    done
    ;;
  --cpu)
    echo "Running CPU stress..."
    sudo -u "$SVC_NAME" stress-ng --cpu 2 --timeout 30s
    ;;
  --mem)
    echo "Running Memory stress..."
    sudo -u "$SVC_NAME" stress-ng --vm 1 --vm-bytes 200M --timeout 30s
    ;;
  --all)
    echo "Running combined stress test..."
    for i in $(seq 1 25); do
      sudo dd if=/dev/urandom of="$MOUNT_DIR/file_$i.dat" bs=10M count=1 status=none 2>/dev/null
    done
    sudo -u "$SVC_NAME" stress-ng --cpu 2 --vm 1 --vm-bytes 200M --timeout 30s &
    ;;
  *)
    echo "Usage: $0 {--disk|--cpu|--mem|--all}"
    exit 1
    ;;
esac
