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

source (status dirname)/../lib/k8s.fish

check_namespace
set POD (get_pod)
set MOODLE_PATH /bitnami/moodle
set BACKUPS_PATH /opt/moodledata/backups

function delete_course
    kubectl exec -n$NS $POD -- moosh --no-user-check --moodle-path $MOODLE_PATH course-delete $argv[1]
end

if contains -- --all $argv
    echo "Deleting all backups in $BACKUPS_PATH and their corresponding courses"
    set mbzs (kubectl exec -n$NS $POD -- ls $BACKUPS_PATH)
    for file in $mbzs
        # extract the course number from the filename
        set course (string match -r -g 'backup_([0-9]+)_' $file)
        delete_course $course
        # if successful, delete the backup
        if test $status -eq 0
            kubectl exec -n$NS $POD -- sh -c "rm -v $BACKUPS_PATH/$file"
        else
            echo "Error deleting course no. $course - the backup file $file will not be deleted" 1>&2
        end
    end
else
    for course in $argv
        delete_course $course
        if test $status -eq 0
            kubectl exec -n$NS $POD -- sh -c "rm -v $BACKUPS_PATH/backup_$course\_*"
        else
            echo "Error deleting course no. $course - the backup file $file will not be deleted" 1>&2
        end
    end
end
