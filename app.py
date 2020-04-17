"""
usage: python3 app.py
takes courses.csv and creates modified-courses.csv with the backup file info
may need to edit fieldnames and the hardcoded filenames if those change
"""
import csv
from backups import backups

# copy from first row of course CSV
fieldnames = ('Moodle ID', 'Category', 'Term', 'Shortname', 'Fullname', 'Instructors', 'Instructor Emails', 'Enrolled', 'Hits', 'Visibility', 'Contained In')

with open('courses.csv', 'r') as infile:
    with open('courses-modified.csv', 'w') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in reader:
            # backups is a dict of backup-file-name to list-of-course-IDs mappings
            for backup, ids in backups.items():
                if row['Moodle ID'] in ids:
                    row["Contained In"] = backup
                    break
            writer.writerow(row)
