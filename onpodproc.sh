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
    $PREFIX moosh --no-user-check --moodle-path ${MOODLE_PATH} course-backup --path ${BACKUPS_PATH} "${ID}" \
        && $PREFIX gsutil cp /opt/moodledata/backups/backup_"${ID}"_* gs://moodle-course-archive/${SEMESTER}/ 2>&1 | (head -n1 && tail -n1) \
        && rm -v /opt/moodledata/backups/backup_"${ID}"_*
}

# redirect all of block's output to LOGFILE
{
echo "$(date) Backing up first ${N} courses in ${IDFILE}"

if which cpulimit >/dev/null; then
    echo "Using cpulimit to restrict python3 and moosh cpu usage"
    cpulimit --exe python3 --limit 10 --background >/dev/null
    cpulimit --path /usr/local/bin/moosh --limit 20 --background >/dev/null
elif command -v nice >/dev/null; then
    # make command's nicer
    echo "Using nice to restrict process resource usage"
    set PREFIX="nice"
else
    echo "WARN cpulimit is not installed so backup processes may take up so much CPU that they affect the Moodle application. It's recommended that you \"install_packages cpulimit\" before running this script."
fi

for COURSE in $(head -n "$N" $IDFILE); do
    echo "$(date) Backing up course number $COURSE"
    backup "$COURSE" && echo "$(date) Done backing up course $COURSE" \
        || echo "$(date) ERROR backing up course $COURSE"
    sed -i -e "/^$COURSE\$/d" $IDFILE
done

echo "$(date) Done backing up ${N} courses"
} 2>&1 | tee -a $LOGFILE
