#!/usr/bin/env fish
function usage
    set_color --bold
    echo copy
    set_color normal
    echo -e '\tbackup retrieve [-s, --semester TERM] QUERY\n'
    echo -e 'Find & download the course backup in GSB.\n'
    echo 'Specifying a TERM is optional but helps in disambiguating backups.'
    echo \
        'The QUERY can be anything contained in a backup filename. Backup filenames
include the course Moodle ID number and the complete shortname (section code).
Ex: backup_3040_VISST-300-03-2017SU_2020.03.22.mbz'
    echo -e "\nExamples:"
    echo -e "\t./backup.fish ret -s 2019FA COMIC-666"
    echo -e "\t./backup.fish ret ANIMA-1000-1-2018FA"
    echo -e "\t./backup.fish ret 3040"
end

switch $argv[1]
    case -h h --help help ''
        usage
        exit

        # parse semester argument if it's present
        # @TODO: contains code that's also in copy.fish so maybe
        # this should be abstracted out into a lib function
    case -s --semester
        set semester (string match -r '[0-9]{4}[A-Z]{2}' "$argv[2]")
        set query "$argv[3]"
        set files $argv[2..-1]
        if test -z $semester
            set_color --bold red
            echo 'Error: must provide a semester string of form "2022FA".'
            set_color normal
            exit 1
        end

    case '*'
        set query "$argv[1]"
end

set GSB gs://moodle-course-archive

function count_courses
    set num (count $argv)
    switch $num
        case 0
            echo "Unable to find any courses matching the query. Double check your query and the backups index spreadsheet to ensure that a backup exists for this course." >&2
            exit 1
        case 1
            echo "Downloading backup file" $argv "to the data directory"
            gsutil -m cp $argv data/
            exit 0
        case '*'
            echo "Multiple backups matched the query:" >&2
            echo $argv | tr ' ' '\n' >&2
            exit 1
    end
end

# https://cloud.google.com/storage/docs/gsutil/addlhelp/WildcardNames
if test -z $semester
    set courses (gsutil ls $GSB'/**/*'$query'*')
    count_courses $courses
else
    set courses (gsutil ls $GSB/$semester/'*'$query'*')
    count_courses $courses
end
