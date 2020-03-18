#!/usr/bin/env bash
# create database
csvsql --db sqlite:///courses.db --table courses --insert file.csv
# add to already-existing database
csvsql --db sqlite:///courses.db --table courses --no-create --insert file.csv
