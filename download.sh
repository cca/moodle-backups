#!/usr/bin/env bash
scp moodle:~/mdl-backup.log data
scp moodle:~/backups.tar.gz backups
ssh moodle 'rm -v ~/backups.tar.gz'
