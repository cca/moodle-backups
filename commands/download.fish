function usage
    set_color --bold
    echo create
    set_color normal
    echo '\tbackup dl [FILE FILE2 | --all]'
    echo '\tDownload backup files from the Moodle server.'
end

switch $argv[1]
    case -h h --help help
        usage
        exit
end

set BACKUPS_PATH /bitnami/moodledata/backups
if contains --all $argv
    # @TODO make this work
    kubectl cp $NS/$POD:$BACKUPS_PATH ../data
end
