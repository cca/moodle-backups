#!/usr/bin/env bash
# this requires adding google-cloud-cli to the pod & authenticating
MOODLE_PATH=/bitnami/moodle
BACKUPS_PATH=/opt/moodledata/backups
SEMESTER="2021SP"
IDFILE="ids.csv"
LOGFILE="/bitnami/moodledata/backups.log"
# LINES is a shell variable, can't use it
N=${1:-5}
# use our timezone (for `date` commands)
export TZ=America/Los_Angeles

backup() {
    ID="$1"
    # use `nice` to stop processes for taking up all the CPU from the running application
    # gsutil has a progress indicator that cannot be turned off, we only want 1st & last line of output
    nice moosh --no-user-check --moodle-path ${MOODLE_PATH} course-backup --path ${BACKUPS_PATH} "${ID}" \
        && nice gsutil cp /opt/moodledata/backups/backup_"${ID}"_* gs://moodle-course-archive/${SEMESTER}/ 2>&1 | (head -n1 && tail -n1) \
        && nice rm -v /opt/moodledata/backups/backup_"${ID}"_*
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

# fix file permissions because script was run as root
nice find /opt/moodledata -type f -user root -exec chown daemon:daemon {} \;
