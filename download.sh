#!/usr/bin/env bash
rsync -vhP ma:~/backups/log.txt data/$(date "+%Y-%m-%d").log
rsync -vhP ma:~/backups.tar backups && ssh ma 'rm -v ~/backups.tar'
