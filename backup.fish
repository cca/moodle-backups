#!/usr/bin/env fish
function usage -d 'describes how to use this script'
    set name (basename (status -f))
    echo "Backup Moodle course to Google Storage."
    echo -e "\nUsage:"
    echo -e "\t$name cp SEMESTER FILE - copy file to semester folder in GSB"
    echo -e "\nExamples:"
    echo -e "\t$name cp 2017SU backup_3040_VISST-300-03-2017SU_2020.03.22.mbz"
end

function cp_backup_to_gsb -d 'copy a single backup file to GSB and then delete it locally'
    set semester $argv[1]
    set file $argv[2]
    if test -z $semester
        set_color --bold red
        echo "Error: must provide a semester string."
        set_color normal
        exit 1
    else if test -z $file; or not test -e $file
        set_color --bold red
        echo "Error: must provide a path to a backup file."
        set_color normal
        exit 1
    end
    gsutil cp $file gs://moodle-course-archive/$semester/(basename $file)
    and rm -v $file
end

switch $argv[1]
    case cp
        cp_backup_to_gsb $argv[2] $argv[3]
    case '*'
        usage
end
