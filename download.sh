#!/usr/bin/env bash
scp moodle:~/mdl-backup.log data/$(date "+%Y-%m-%d").log
scp moodle:~/backups.tar.gz backups
ssh moodle 'rm -v ~/backups.tar.gz'
