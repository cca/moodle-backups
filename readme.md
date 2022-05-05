# Moodle Backups

**WIP** this project is undergoing a major renovation.

Backup old Moodle courses to a Google Storage Bucket with a slower storage class.

## Setup

Requires fish shell, [gsutil](https://cloud.google.com/storage/docs/gsutil_install), and kubectl. Fish and kubectl are in [homebrew](https://brew.sh).

```sh
> brew install fish kubectl
> # Or install using gcloud. Do not install kubectl with both
> glcoud install gsutil kubectl
```

We'll need access to the Moodle Course Archive storage bucket as well as the Moodle kubernetes cluster.

## Setup (old)

(old) Create an ssh alias named "moodle" for your Moodle server. Install [moosh](https://moosh-online.com) on the Moodle server.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
