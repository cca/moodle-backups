#!/usr/bin/env bash

COURSES=$(cat ids.txt)
cd /opt/moodle

timestamp () { date "+%Y-%m-%d %H:%m" | sed -e 's/\n/ /' >> ${HOME}/mdl-backup.log; }

delete () {
    timestamp
    sudo -u www-data moosh course-delete $1 >> ${HOME}/mdl-backup.log
}

for id in $COURSES; do
    delete $id
done
