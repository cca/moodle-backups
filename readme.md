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
1. Delete the backups file and the courses
    + Use Moodle's "Manage courses and categories" tool to delete a shared parent category, this should trickle down and delete all child courses
    + Alternatively, `ssh` back into Moodle, run del.sh to delete only the courses you backed up
