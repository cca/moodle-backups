#!/usr/bin/env bash

COURSES=$(cat ids.txt)
cd /opt/moodle

timestamp () { echo -n $(date "+%Y-%m-%d %H:%M")" " >> ${HOME}/mdl-backup.log; }

backup () {
    timestamp
    sudo -u www-data moosh course-backup $1 >> ${HOME}/mdl-backup.log
}

for id in $COURSES; do
    backup $id
done

timestamp
echo "Creating a compressed archive of all course backups..." >> ${HOME}/mdl-backup.log
tar czf backups.tar.gz backup_*
mv backups.tar.gz $HOME
rm backup_*
timestamp
echo "Finished." >> ${HOME}/mdl-backup.log
