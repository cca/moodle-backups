#!/usr/bin/env bash
# this requires adding google-cloud-cli to the pod & authenticating
MOODLE_PATH=/bitnami/moodle
BACKUPS_PATH=/opt/moodledata/backups
SEMESTER="2020FA"
IDFILE="ids.csv"
LOGFILE="/bitnami/moodledata/backups.log"
# LINES is a shell variable, can't use it
N=${1:-5}

backup() {
    ID="$1"
    # gsutil has a progress indicator that cannot be turned off, we only want 1st & last line of output
    moosh --no-user-check --moodle-path ${MOODLE_PATH} course-backup --path ${BACKUPS_PATH} "${ID}" \
        && gsutil cp /opt/moodledata/backups/backup_"${ID}"_* gs://moodle-course-archive/${SEMESTER}/ >/dev/null \
        && rm -v /opt/moodledata/backups/backup_"${ID}"_*
}

# redirect all of block's output to LOGFILE
{
echo "$(date) Backing up first ${N} courses in ${IDFILE}"

for COURSE in $(head -n "$N" $IDFILE); do
    echo "$(date) Backing up course number $COURSE"
    backup "$COURSE" && echo "$(date) Done backing up course $COURSE" \
        || echo "$(date) ERROR backing up course $COURSE"
    sed -i -e "/^$COURSE\$/d" $IDFILE
done

echo "$(date) Done backing up ${N} courses"
} 2>&1 | tee -a $LOGFILE
