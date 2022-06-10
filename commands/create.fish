function usage
    set_color --bold
    echo create
    set_color normal
    echo '\tbackup create COURSE [COURSE2 COURSE3...]'
    echo '\tGiven course ID number(s), create backup files on the Moodle server.'
end

switch $argv[1]
    case -h h --help help
        usage
        exit
end

# @TODO should be its own `namespace_check` command because it'll be reused?
if not test $NS = moo-prod && not test $NS = moo-stg1
    set_color red
    echo 'Error: commands interacting with the remote Moodle kubernetes clusters require a NS namespace environment variable of either "moo-prod" (for production) or "moo-stg1" (for staging).'
    exit 1
end

# @TODO this also should be its own `get_pod` command because multiple will need it
set POD (kubectl -n$NS get pods -o custom-columns=":metadata.name" | grep moodle)
if test -z $POD
    set_color red
    echo 'Error: unable to find the Moodle application pod.'
    set_color normal
    echo 'Are you sure you are connected to the right cluster?'
    echo 'If you have the "k8" command from the libraries kubernetes tools, you can run "k8 pod" to switch to the cluster that matches your NS namespace variable.'
    echo 'Read more here: https://github.com/cca/libraries-k8s#helper-scripts'
    kubectl -n$NS get pods -o
end

set MOODLE_PATH /bitnami/moodle
set BACKUPS_PATH /bitnami/moodledata/backups

for course in $argv
    # this prints a lot of noise but the final message is the complete path of the .mbz file
    kubectl exec -n$NS $POD -- moosh --no-user-check --moodle-path $MOODLE_PATH course-backup --path $BACKUPS_PATH $course
end
