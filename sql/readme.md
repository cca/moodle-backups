# Moodle Backups Index

We use SQL queries and the **Ad-hoc database queries** plugin to store information on which courses we've chosen to backup so we can retrieve them later, even if we're given only limited information like the instructor's name and an approximate course title.

## End-of-term backup information

- Run the [Backups Index Report](https://moodle.cca.edu/report/customsql/view.php?id=30) using the current term's code like `2022SU` during the last week of that term
- Save the report's results to the data directory
- Append the report's rows to the [Backups Index Spreadsheet](https://docs.google.com/spreadsheets/d/1mxO2PbKk088R9e3rU_XwUpxV_HwzIKBiIrK1xPy3zfU/edit) in Drive

Then, when the time comes two years later to make backups from that term, we can use the spreadsheet to determine which courses were in use. Good guidelines are one that either 1) are visible, 2) have >100 "hits", or 3) have a large number of course modules (>12 is probably a good guideline).
