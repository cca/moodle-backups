#!/usr/bin/env fish
function usage -d 'describes how to use this script'
    set name (basename (status -f))
    echo "Backup Moodle course to Google Storage."
    echo -e "\nCommands:"
    echo -e "\t./$name mk COURSE1 [ COURSE2 COURSE3... ] - create a backup on the Moodle pod"
    echo -e "\t./$name dl [ COURSE1 COURSE2... | --all ] - download specific, or all, backup files from the Moodle pod"
    echo -e "\t./$name cp SEMESTER FILE1 [FILE2 FILE3...] - copy backup file(s) to SEMESTER folder in GSB"
    echo -e "\t./$name rm [ COURSE1 COURSE2... | --all ] - delete specific, or all, backup files from the Moodle pod"
end

switch $argv[1]
    case create mk
        ./commands/create.fish $argv[2..-1]
    case download dl
        ./commands/download.fish $argv[2..-1]
    case copy move cp mv
        ./commands/copy.fish $argv[2..-1]
    case rm remove del delete
        ./commands/delete.fish $argv[2..-1]
    case '*'
        usage
end
