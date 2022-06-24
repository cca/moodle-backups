#!/usr/bin/env bash

COURSES=$(cat ids.txt)
TOTAL=$(wc -l ids.txt | sed 's/ .*//')
COUNT="1"
mkdir -p /Users/ephetteplace/backups
cd /opt/moodle

timestamp () { echo -n $(date "+%Y-%m-%d %H:%M")" "; }

backup () {
    timestamp
    sudo -u www-data moosh course-backup --path /Users/ephetteplace/backups $1 \
    && sudo -u www-data moosh course-delete $1
}

timestamp
echo 'disk usage before backup'
df -H

for id in $COURSES; do
    echo "Backing up course ${COUNT} of ${TOTAL}"
    backup $id
    COUNT=$(expr $COUNT + 1)
done

timestamp
echo "Creating a compressed archive of all course backups..."
tar cf /Users/ephetteplace/backups.tar /Users/ephetteplace/backups/backup_*
rm /Users/ephetteplace/backups/backup_*
timestamp
echo "Finished."

timestamp
echo 'Flushing temp/backup and trashdir directories on data drive'
sudo -u www-data moosh file-delete --flush

timestamp
echo 'disk usage after backup'
df -H
