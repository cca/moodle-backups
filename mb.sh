#!/usr/bin/env bash

COURSES=$(cat ids.txt)
TOTAL=$(wc -l ids.txt | sed 's/ .*//')
COUNT="1"
BACKUPS_DIR="/Users/ephetteplace/moodle-backups/backups"

mkdir -p ${BACKUPS_DIR}
cd /opt/moodle

timestamp () { echo -n $(date "+%Y-%m-%d %H:%M")" "; }

backup () {
    timestamp
    sudo moosh -n course-backup --path ${BACKUPS_DIR} $1
    # && sudo moosh -n course-delete $1
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
tar cf /Users/ephetteplace/backups.tar ${BACKUPS_DIR}/backup_* \
    && rm ${BACKUPS_DIR}/backup_*
timestamp
echo "Finished."

echo 'Flushing temp/backup and trashdir directories on data drive'
sudo moosh -n file-delete --flush

timestamp
echo 'disk usage after backup'
df -H
