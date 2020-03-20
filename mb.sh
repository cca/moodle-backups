#!/usr/bin/env bash

COURSES=$(cat ids.txt)
TOTAL=$(wc -l ids.txt | sed 's/ .*//')
COUNT="1"
cd /opt/moodle

timestamp () { echo -n $(date "+%Y-%m-%d %H:%M")" " >> ${HOME}/mdl-backup.log; }

backup () {
    timestamp
    sudo -u www-data moosh course-backup $1 >> ${HOME}/mdl-backup.log \
    && sudo -u www-data moosh course-delete $1 >> ${HOME}/mdl-backup.log
}

timestamp
echo 'disk usage before backup'
df -H >> ${HOME}/mdl-backup.log

for id in $COURSES; do
    echo "Backing up course ${COUNT} of ${TOTAL}"
    backup $id
    COUNT=$(expr $COUNT + 1)
done

timestamp
echo "Creating a compressed archive of all course backups..." >> ${HOME}/mdl-backup.log
tar czf backups.tar.gz backup_*
mv backups.tar.gz $HOME
rm backup_*
timestamp
echo "Finished." >> ${HOME}/mdl-backup.log

timestamp
echo 'Flushing temp/backup and trashdir directories on data drive'
rm -rf /data/temp/backup
sudo -u www-data moosh file-delete --flush

timestamp
echo 'disk usage after backup'
df -H >> ${HOME}/mdl-backup.log
