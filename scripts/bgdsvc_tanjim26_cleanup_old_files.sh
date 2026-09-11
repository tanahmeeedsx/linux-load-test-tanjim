#!/bin/bash
TMPDIR="/mnt/bgdsvc_tanjim26_tmp"
LOGFILE="/var/log/bgdsvc_tanjim26/monitor.log"
find "$TMPDIR" -type f -mtime +1 -delete 2>/dev/null
echo "$(date): cleanup executed" >> "$LOGFILE"
