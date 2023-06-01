# Moodle Backups

Backup old Moodle courses to a Google Storage Bucket with a slower storage class.

We replaced the old Google Drive archive of Moodle course backups with one stored in a Google Storage Bucket (GSB). Backup files are stored initially in the "coldline" storage class, reduced to "archive" after 240 days, and then deleted after 730 days using GSB Lifecycle Rules. The goal of using GSB like this is to save money, make management easier (e.g. the lifecycle automation), and make backups more programmatically accessible. We have [a spreadsheet index](https://docs.google.com/spreadsheets/d/1mxO2PbKk088R9e3rU_XwUpxV_HwzIKBiIrK1xPy3zfU/edit?usp=sharing) of course backups in the Libraries' InST Shared Drive folder which is used to identify backups for retrieval.

## Setup

Requires [fish shell](https://fishshell.com/), [gsutil](https://cloud.google.com/storage/docs/gsutil_install), and [kubectl](https://kubernetes.io/docs/reference/kubectl/). Fish and kubectl are in [homebrew](https://brew.sh).

```sh
> brew install fish kubectl
> # Or install using gcloud. Do not install kubectl with both
> glcoud install gsutil kubectl
```

We'll also need access to the [Moodle Course Archive](https://console.cloud.google.com/storage/browser/moodle-course-archive;tab=objects?project=cca-web-0) storage bucket as well as all of the Moodle kubernetes clusters (a "staging" `kubectl` context for tests and a "production" `kubectl` context for actual backups).

## Semester Backup Workflow

After a semester concludes, run the [Backups Index Report](https://moodle.cca.edu/report/customsql/view.php?id=30) for it and append its results to the Backups Index in Drive.

Two years after a semester has concluded, we can backup "used" courses in GSB and delete them from Moodle:

- consult the Backups Index to determine which courses to backup
  - our criteria tends to factor in course usage, number of modules, and visibility
  - export a list of course ID numbers (with no header row) and save it as data/ids.csv
- run the included proc.fish script to iterate over ids.csv, its steps are
  - `./backup mk 1234` backup a course
  - `./backup dl --all` download all the backup files to the data dir
  - `./backup cp $SEMESTER data/backup_*` transfer files to GSB (note: avoid copying any test files in the data dir)
  - `./backup rm --all` delete the courses & their backups on the pod

The proc.fish script is designed to fully process courses one at a time so as to limit the disk space impact on the Moodle container. However, every time a course is backed up, the .mbz backup file is stored in the Recycle Bin for a configurable amount of time (see [the settings](https://moodle.cca.edu/admin/settings.php?section=tool_recyclebin)). It may be necessary to pause sometimes until the bin is emptied. We can monitor these backup files with the [Backups in the Recycle Bin](https://moodle.cca.edu/report/customsql/view.php?id=15) report and the size of the "trashdir" directory underneath Moodle's data directory.

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
parallel_composite_upload_threshold = 100M
parallel_composite_upload_component_size = 50M
```

Alternatively, set the `parallel_composite_upload_threshold` to `0` to disable this message and then the `gsutil` clients that download files added without the parallel composite upload won't need crcmod. In testing, files uploaded as composite objects are able to be downloaded via the Google Cloud Console, so they can still be accessed from machines without a compiled crcmod.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
