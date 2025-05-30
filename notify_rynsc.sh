#!/bin/bash

LOGFILE="/opt/scripts/rsync_debug.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "[$(date)] Starting rsync transfer"

# Example rsync
rsync -avz -e ssh vzpipview@tdclpalrba002.verizon.com:/dataserver/lqextracts/ vzpipview@tpalpalrba006.verizon.com:/dataserver/lqextracts/

echo "[$(date)] Rsync Completed"

# Email notification
echo "Rsync job completed" | mail -s "Rsync Completed" your-email@example.com
