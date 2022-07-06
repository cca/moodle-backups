#!/usr/bin/env bash
rsync -vhP ma:~/moodle-backups/data/log.txt data/$(date "+%Y-%m-%d").log
rsync -vhP ma:~/backups.tar data/ && ssh ma 'rm -v ~/backups.tar'
