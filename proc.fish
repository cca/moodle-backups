#!/usr/bin/env fish
# backup several courses at once iterating over a file of course ID numbers
# usage: ./proc.fish [N]
# where N is the number of backups to make

# defaults
# @TODO IDFILE should be a parameter, too
set IDFILE data/ids.csv
set LINES 5
set LOGFILE data/(dt).log

# number of backups to make
if string match --regex --quiet '[0-9]+' $argv[1]
    set LINES $argv[1]
end

set_color --bold
echo (date) "Backing up $LINES courses from list of IDs in $IDFILE"
set_color normal

for id in (head -n $LINES $IDFILE)
    begin
        echo (date) "Backing up course $id"
        ./backup.fish mk $id
        # @TODO if there's a random backup not created by this script it'll get
        # downloaded over & over; may need to catch the complete backup filename
        # from the last command & download just that
        and ./backup.fish dl --all
        and ./backup.fish cp 2020FA data/backup_"$id"_*
        and ./backup.fish rm $id
    end &>>$LOGFILE

    if test $status -ne 0
        set_color red
        echo (date) "ERROR: problem while backing up course $id" >>$LOGFILE
        set_color normal
    else
        echo (date) "Successfully backed up course $id" >>$LOGFILE
        gsed -i -e "/^$id\$/d" $IDFILE
    end
end

set_color --bold
echo (date) "Finished backing up $LINES courses."
set_color normal
