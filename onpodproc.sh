#!/usr/bin/env bash
set -euo pipefail # bash strice mode: stop on error, unset variables, or pipe fails
# this requires adding google-cloud-cli to the pod & authenticating
MOODLE_PATH=/bitnami/moodle
BACKUPS_PATH=/opt/moodledata/backups
SEMESTER="2021FA"
IDFILE="ids.csv"
LOGFILE="/bitnami/moodledata/backups.log"
# LINES is a shell variable, can't use it
N=${1:-5}
CONFIRM=${2-n}
# use our timezone (for `date` commands)
export TZ=America/Los_Angeles

echo "Backing up first ${N} courses in ${IDFILE} to ${SEMESTER} folder in GSB, logs to ${LOGFILE}"

# if CONFIRM looks like "yes" (y, yes, -y, -yes) then continue, otherwise confirm
if [[ ! "$CONFIRM" =~ ^-?[yY](es)?$ ]]; then
    echo "Sound good? [y/n]"
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY](es)?$ ]]; then
        echo "Exiting without backing up courses"
        exit 1
    fi
fi

backup() {
    ID="$1"
    # use `nice` to stop processes for taking up all the CPU from the running application
    # gsutil has a progress indicator that cannot be turned off, we only want 1st & last line of output
    nice moosh --no-user-check --moodle-path ${MOODLE_PATH} course-backup --path ${BACKUPS_PATH} "${ID}" \
        && nice gsutil -m cp /opt/moodledata/backups/backup_"${ID}"_* gs://moodle-course-archive/${SEMESTER}/ 2>&1 | (head -n1 && tail -n1) \
        && nice rm -v /opt/moodledata/backups/backup_"${ID}"_*
}

# redirect all of block's output to LOGFILE
{
for COURSE in $(head -n "$N" $IDFILE); do
    echo "$(date) Backing up course number $COURSE"
    backup "$COURSE" && echo "$(date) Done backing up course $COURSE" \
        || echo "$(date) ERROR backing up course $COURSE"
    sed -i -e "/^$COURSE\$/d" $IDFILE
done

echo "$(date) Done backing up ${N} courses"
} 2>&1 | tee -a $LOGFILE

# fix file permissions because script was run as root
nice find /opt/moodledata -type f -user root -exec chown daemon:daemon {} \;
