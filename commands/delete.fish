#!/usr/bin/env fish
function usage
    set_color --bold
    echo delete
    set_color normal
    echo -e '\t./backup.fish rm [ COURSE1 COURSE2 COURSE3... | --all ]\n'
    echo 'Delete backup files and backed up courses from Moodle.'
    echo -e "\nExamples:"
    echo -e "\t./backup.fish delete 3606"
    echo -e "\t./backup.fish rm --all"
end

switch $argv[1]
    case -h h --help help ''
        usage
        exit
end
