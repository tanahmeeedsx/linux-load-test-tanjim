#!/bin/bash
export SVC_NAME="bgdsvc_tanjim26"

if id "$SVC_NAME" &>/dev/null; then
    echo "User $SVC_NAME already exists."
else
    sudo useradd -r -m -s /usr/sbin/nologin "$SVC_NAME"
    echo "User $SVC_NAME created successfully."
fi
