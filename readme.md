# Moodle Backups

Backup old Moodle courses to a Google Storage Bucket with a slower storage class.

Backups are stored initially in the "coldline" storage class, reduced to "archive" after 240 days, and then deleted after 730 days using GSB Lifecycle Rules. The goal of using GSB is to save money, make management easier (e.g. the lifecycle automation), and make backups programmatically accessible. We have [a spreadsheet index](https://docs.google.com/spreadsheets/d/1mxO2PbKk088R9e3rU_XwUpxV_HwzIKBiIrK1xPy3zfU/edit?usp=sharing) of backups in the Libraries' InST Shared Drive folder which is used to identify backups for retrieval.

## Setup

Requires [fish shell](https://fishshell.com/), [gsutil](https://cloud.google.com/storage/docs/gsutil_install), and [kubectl](https://kubernetes.io/docs/reference/kubectl/). Fish and kubectl are in [homebrew](https://brew.sh).

```sh
> brew install fish kubectl
> # Or install using gcloud. Do not install kubectl with both
> glcoud install gsutil kubectl
```

We also need access to the [Moodle Course Archive](https://console.cloud.google.com/storage/browser/moodle-course-archive;tab=objects?project=cca-web-0) storage bucket as well as all of the Moodle kubernetes clusters (a "staging" `kubectl` context for tests and a "production" `kubectl` context for actual backups).

## Semester Backup Workflow

After a semester concludes, run the [Backups Index Report](https://moodle.cca.edu/report/customsql/view.php?id=30) for it and append its results to the Backups Index in Drive.

Two years after a semester has concluded, we can backup "used" courses in GSB and delete them from Moodle:

- consult the Backups Index to determine which courses to backup
  - our criteria tends to factor in course usage, number of modules, and visibility
  - start with the Metacourses category (see below)
  - export a list of course ID numbers (with no header row) and save it as data/ids.csv
- use one of the included backup procedures below

We backup the Metacourses category first because we don't want to delete the composite sections before the parent metacourse, then the metacourse backup will lack enrollments and their associated student work.

### In the cloud (recommended)

Setup:

- in GCP, go to IAM > Service Accounts, find the `moodle-backups` service account (SA)
- create a JSON key file for the SA ("more" Actions > Manage keys)
- transfer the key file to the pod (e.g. `kubectl cp key.json POD:/bitnami/moodledata/key.json`)
- prepare the pod to use google cloud utilities (Google has [official installation documentation](https://cloud.google.com/storage/docs/gsutil_install) that didn't fully work for me):

```sh
install_packages apt-transport-https ca-certificates gnupg curl
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg
apt-key add /usr/share/keyrings/cloud.google.gpg
install_packages google-cloud-cli
gcloud auth activate-service-account --key-file /bitnami/moodledata/key.json
```

Finally, to take advantage of speedier composite uploads, you'll need to edit the service account's .boto file (located somewhere under /.config/gcloud/legacy_credentials/) to add the properties described in the "gsutil composite objects & CRC Mod" section below. The SA has Storage Object Admin permission on the course archive bucket in order to take advantage of composite uploads.

Once ready, run onpodproc.sh on the container. It backs up 5 courses (or `./onpodproc N` to backup N at a time) from the list of IDs in ids.csv and writes to a log file.

It's best to delete the service account key (IAM > Service Accounts > moodle-backups > Manage Keys) when backups are done and to create a new key for the next time we need to backup courses.

### Via laptop

This method is a little easier to manage but introduces an extra network transfer (pod -> laptop -> storage instead of pod -> storage) and tends to be _much_ slower when running over a consumer internet connection with mediocre upload speeds.

- run the included proc.fish script to iterate over ids.csv, its steps are
  - `./backup mk 1234` backup a course
  - `./backup dl --all` download all the backup files to the data dir
  - `./backup cp $SEMESTER data/backup_*` transfer files to GSB (note: avoid copying any test files in the data dir)
  - `./backup rm --all` delete the courses & their backups on the pod

### Backups in recycle bin

Every time a course is backed up, the .mbz backup file is stored in the Recycle Bin for a configurable amount of time (see [the settings](https://moodle.cca.edu/admin/settings.php?section=tool_recyclebin)). It may be necessary to pause in the middle of a large number of backups sometimes until the bin is emptied. We can monitor these backup files with the [Backups in the Recycle Bin](https://moodle.cca.edu/report/customsql/view.php?id=15) report and the size of the "trashdir" directory underneath Moodle's data directory.

### Deleted courses recreated

When we delete a course from Moodle, its enrollments still exist in the Moodle support database, and thus during the next enrollment sync they will be recreated. We don't want to delete all of the old term's enrollments out of the support db _before_ performing backups, because then users will be removed from the course and the backup that's created won't reflect the real enrollment. The best way to manage this is to piecemeal backup courses in chunks, removing their entries from the support db at the same time as you delete the courses in Moodle. Course categories are a convenient way of chunking courses and make it easier to delete things in bulk:

```sh
# say we've finished backing up course categories 100 - 105
# categories are mostly numbered to match their alphabetical order but things like "metacourses" can be exceptions
# on the Moodle container:
for cat in (seq 100 105); do moosh -n category-delete $cat; done
```

```sql
-- in the support db:
DELETE FROM enrollments WHERE category_id IN (100, 101, 102, 103, 104, 105)
```

## Retrieving backups

When we need a backup, `./backup retrieve $QUERY` retrieves it from the archive.

## Testing

```sh
> # run all tests
> test/test
> # test a specific command (or set of commands)
> test/test create
```

Tests run against the staging Moodle cluster. The ID for a particular course (3606) in our staging instance is hard-coded into one test but can be overridden with a `TEST_COURSE` enrivonment variable.

## gsutil composite objects & CRC Mod

`gsutil` prints this notice if we try to upload a large file:

> ==> NOTE: You are uploading one or more large file(s), which would run significantly faster if you enable parallel composite uploads. This feature can be enabled by editing the  "parallel_composite_upload_threshold" value in your .boto configuration file. However, note that if you do this large files will be uploaded as `composite objects <https://cloud.google.com/storage/docs/composite-objects>`_, which means that any user who downloads such objects will need to have a compiled crcmod installed (see "gsutil help crcmod"). This is because without a compiled crcmod, computing checksums on composite objects is so slow that gsutil disables downloads of composite objects.

Check if a compiled CRC mod is available with `gsutil version -l` (it'll say "compiled crcmod: True"). If not, run `pip3 install -U crcmod` to install it. If pip claims it's already installed, it might not be running in the same python environment gsutil is using. Look at `gcloud info` for the Python Location and then run `$PYTHON_LOCATION -m pip install -U crcmod` (see [this comment](https://github.com/GoogleCloudPlatform/gsutil/issues/1123#issuecomment-772588861)). Finally, edit the .boto configuration file in your user's home directory to [enable parallel composite uploads](https://cloud.google.com/storage/docs/uploads-downloads#parallel-composite-uploads):

```ini
[GSUtil]
parallel_composite_upload_threshold = 100M
parallel_composite_upload_component_size = 50M
```

Alternatively, set the `parallel_composite_upload_threshold` to `0` to disable this message and then the `gsutil` clients that download files added without the parallel composite upload won't need crcmod. In testing, files uploaded as composite objects are able to be downloaded via the Google Cloud Console, so they can still be accessed from machines without a compiled crcmod.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
