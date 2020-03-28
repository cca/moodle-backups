#!/usr/bin/env bash
rsync -vhP moodle:~/mdl-backup.log data/$(date "+%Y-%m-%d").log
rsync -vhP moodle:~/backups.tar.gz backups
ssh moodle 'rm -v ~/backups.tar.gz'
