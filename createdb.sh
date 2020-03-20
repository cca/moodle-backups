#!/usr/bin/env bash
# create database
csvsql --db sqlite:///courses.db --table courses --insert file.csv
# add to already-existing database
csvsql --db sqlite:///courses.db --table courses --no-create --insert file.csv
# query spreadsheet and get a list of IDs, can change the semester code here
TERM="2018SP"
csvsql --query "SELECT * FROM '${TERM}' WHERE Visibility = 'visible' OR Hits > 99" data/${TERM}.csv | csvcut -c 1 | sed 's/\.0//' > data/${TERM}.txt
