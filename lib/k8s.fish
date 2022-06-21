function check_namespace
    if not test "$NS" = 'moo-prod'; and not test "$NS" = 'moo-stg1'
        set_color red
        echo 'Error: commands interacting with the remote Moodle kubernetes clusters require a NS namespace environment variable of either "moo-prod" (for production) or "moo-stg1" (for staging).'
        exit 1
    end
end

function get_pod
    set POD (kubectl -n$NS get pods -o custom-columns=":metadata.name" | grep moodle)
    if test -z $POD
        set_color red
        echo 'Error: unable to find the Moodle application pod.'
        set_color normal
        echo 'Are you sure you are connected to the right cluster?' >2
        echo 'If you have the "k8" command from the libraries kubernetes tools, you can run "k8 pod" to switch to the cluster that matches your NS namespace variable.' >2
        echo 'Read more here: https://github.com/cca/libraries-k8s#helper-scripts' >2
        exit 1
    end
    echo $POD
end
