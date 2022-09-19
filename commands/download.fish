#!/usr/bin/env fish
function usage
    set_color --bold
    echo download
    set_color normal
    echo -e '\t./backup.fish dl [ FILE1 FILE2 FILE3... | --all ]\n'
    echo 'Download backup files from the Moodle server into the "data" directory.'
    echo -e "\nExamples:"
    echo -e "\t./backup.fish download backup_3606_ANIMA-1001-01_2022.06.21.mbz"
    echo -e "\t./backup.fish dl --all"
end

switch $argv[1]
    case -h h --help help ''
        usage
        exit
end

source (status dirname)/../lib/k8s.fish
check_namespace
set -gx POD (get_pod)
set BACKUPS_PATH bitnami/moodledata/backups

if contains -- --all $argv
    echo "Downloading the contents of $BACKUPS_PATH"
    kubectl cp --retries=10 $NS/$POD:$BACKUPS_PATH data
else
    for file in $argv
        # trim leading slash
        set file (string replace -r '^/' '' $file)
        if string match "$BACKUPS_PATH*" $file 2&>/dev/null
            # full path was specified
            echo Downloading (basename $file)
            kubectl cp --retries=10 $NS/$POD:$file data/(basename $file)
        else
            echo "Downloading $file"
            kubectl cp --retries=10 $NS/$POD:$BACKUPS_PATH/$file data/$file
        end
    end
end
