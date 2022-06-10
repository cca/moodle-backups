#!/usr/bin/env fish
function usage -d 'describes how to use this script'
    set name (basename (status -f))
    echo "Backup Moodle course to Google Storage."
    echo -e "\nUsage:"
    echo -e "\t$name cp SEMESTER FILE [FILE2 FILE3...] - copy file(s) to semester folder in GSB"
    echo -e "\nExamples:"
    echo -e "\t$name cp 2017SU backup_3040_VISST-300-03-2017SU_2020.03.22.mbz"
end

# @TODO move to commands/copy.fish script
function cp_backup_to_gsb -d 'copy a single backup file to GSB and then delete it locally'
    set semester (string match -r '[0-9]{4}[A-Z]{2}' "$argv[1]")
    set files $argv[2..-1]
    if test -z $semester
        set_color --bold red
        echo 'Error: must provide a semester string of form "2022FA".'
        set_color normal
        exit 1
    end
    for file in $files
        if test -z $file; or not test -e $file
            set_color --bold red
            echo "Error: $file is not a path to a valid file."
            set_color normal
        else
            gsutil cp $file gs://moodle-course-archive/$semester/(basename $file)
            and echo -n "Deleting "; and rm -v $file
        end
    end
end

switch $argv[1]
    case create mk
        ./commands/create.fish $argv[2..-1]
    case download dl
        ./commands/download.fish $argv[2..-1]
    case copy move cp mv
        cp_backup_to_gsb $argv[2..-1]
    case '*'
        usage
end
