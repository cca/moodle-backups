#!/usr/bin/env bash

COURSES=$(cat ids.txt)
cd /opt/moodle

timestamp () { date "+%Y-%m-%d %H:%m" | sed -e 's/\n/ /' >> ${HOME}/mdl-backup.log; }

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
timestamp
echo "Finished."
