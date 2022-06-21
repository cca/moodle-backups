#!/usr/bin/env fish
function usage
    set_color --bold
    echo copy
    set_color normal
    echo -e '\tbackup cp SEMESTER FILE1 [FILE2 FILE3...]\n'
    echo 'Copy the given backup files to the SEMESTER folder in GSB.'
    echo 'This command removes the local file(s) after completion.'
    echo -e "\nExamples:"
    echo -e "\t./backup.fish cp 2017SU backup_3040_VISST-300-03-2017SU_2020.03.22.mbz"
    echo -e "\t./backup.fish cp 2017FA *.mbz"
end

switch $argv[1]
    case -h h --help help ''
        usage
        exit
end

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
