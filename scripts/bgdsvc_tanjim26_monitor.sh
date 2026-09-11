#!/bin/bash
LOGFILE="/var/log/bgdsvc_tanjim26/monitor.log"
mkdir -p /var/log/bgdsvc_tanjim26
echo "----- $(date) -----" >> "$LOGFILE"
free -h >> "$LOGFILE"
df -h "/mnt/bgdsvc_tanjim26_tmp" >> "$LOGFILE" 2>&1
