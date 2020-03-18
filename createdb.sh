#!/usr/bin/env bash
# create database
csvsql --db sqlite:///courses.db --table courses --insert file.csv
# add to already-existing database
csvsql --db sqlite:///courses.db --table courses --no-create --insert file.csv
# query existing spreadsheet, replace the semester code
csvsql --query "SELECT * FROM '2016SU' WHERE Visibility = 'visible' OR Hits > 99" data/2016SU.csv
