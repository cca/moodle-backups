# Moodle Backups

Shell scripts to help us backup a segment of our Moodle courses. If you want to backup _everything_ at once, there is an admin function for that.

## Setup

Create an ssh alias named "moodle" for your Moodle server.

Install [moosh](https://moosh-online.com) on the Moodle server.

## Workflow

1. Find the course IDs you want to backup
    + CCA has a [query tool](http://moodle.cca.edu/admin/cca_tools/queries/) that can help here, or you can run SQL queries directly on the Moodle databases
    + I included createdb.sh which can help you create a sqlite db from CSVs you download from above, it uses Python's csvkit
1. Add them to an "ids.txt" file, one per line
1. Sync these files to the Moodle server, `ssh` in
1. Run mb.sh on the server to create a compressed archive (will take a while)
1. Exit the server, run download.sh locally
1. Move the backups file to long-term storage
1. Delete the backups file and courses
    + Use Moodle's "Manage courses and categories" tool to delete a shared parent category, this should trickle down and delete all child courses

## Retrieving backed up courses

I wrote a `findclass` utility for searching the compressed backup archives for particular sections. It's usage is `./findclass [SEMESTER] SECTION`:

```sh
> # search a particular semester
> ./findclass 2017FA DMSBA-610-01
> # search for a section across all semeters available in the "backups" directory
> ./findclass ARTED-101-01
> # works for Moodle ID numbers, too
> ./findclass 9348
> # -e or --extract flag also extract the section backup (position of flag doesn't matter)
> ./findclass 2019FA ILLUS-1000-01 --extract
```

The utility returns the first backup found and exits. It exist with a non-zero status failure if no backup is found. It only works on files stored in the "backups" directory and the optional `SEMESTER` parameter expects the backup files to be named like "2018FA[.\*].tar.gz" where the [.\*] can be anything.

## LICENSE

[ECL Version 2.0](https://opensource.org/licenses/ECL-2.0)
