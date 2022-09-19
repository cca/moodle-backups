#!/usr/bin/env fish
function usage
    set_color --bold
    echo create
    set_color normal
    echo -e '\t./backup.fish mk COURSE [COURSE2 COURSE3...]\n'
    echo 'Given course ID number(s), create backup files on the Moodle server.'
    echo -e "\nExamples:"
    echo -e "\t./backup.fish create 1234"
    echo -e "\t./backup.fish mk 1111 1112 1113 1114"
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

# create backups dir in case it does not already exist
kubectl exec -n$NS $POD -- mkdir -p $BACKUPS_PATH
for course in $argv
    echo "Creating backup of course no. $course"
    # this prints a lot of noise but the final message is the complete path of the .mbz file
    kubectl exec -n$NS $POD -- moosh --no-user-check --moodle-path $MOODLE_PATH course-backup --path $BACKUPS_PATH $course
end
