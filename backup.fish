#!/usr/bin/env fish
function usage -d 'describes how to use this script'
    set name (basename (status -f))
    echo "Backup Moodle course to Google Storage."
    echo -e "\nCommands:"
    echo -e "\t./$name mk COURSE1 [ COURSE2 COURSE3... ] - create a backup on the Moodle pod"
    echo -e "\t./$name dl [ COURSE1 COURSE2... | --all ] - download specific, or all, backup files from the Moodle pod"
    echo -e "\t./$name cp SEMESTER FILE1 [FILE2 FILE3...] - copy backup file(s) to SEMESTER folder in GSB"
    echo -e "\t./$name rm COURSE - delete the backup file and course from the Moodle pod"
    echo -e "\t./$name ret QUERY - find & download the course backup from GSB"
    echo -e "\nFor additional usage information, use a -h or --help flag on any subcommand."
end

switch $argv[1]
    case create mk
        fish (status dirname)/commands/create.fish $argv[2..-1]
    case download dl
        fish (status dirname)/commands/download.fish $argv[2..-1]
    case copy move cp mv
        fish (status dirname)/commands/copy.fish $argv[2..-1]
    case rm remove delete
        fish (status dirname)/commands/delete.fish $argv[2..-1]
    case ret retrieve
        fish (status dirname)/commands/retrieve.fish $argv[2..-1]
    case '*'
        usage
end
