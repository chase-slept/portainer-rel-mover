#!/usr/bin/env bash
#
# a script to identify any running Docker containers that use Portainer relative
# paths (./example_container:/config). Moves container data to a new host with
# a more conventional naming scheme

datapath=/data/compose

function path {
    # uses 'find' to print Portainer's data directory structure 
    find $datapath -maxdepth 2 -mindepth 2 -type d -printf '%p\n' | sort
}

function print_docker {
    # lists all running docker containers
    docker ps -a | awk 'NR > 1 {print $NF}' | sort
}

function result {
    # store *running* docker containers in array and determine length
    readarray -t ps_array <<< "$(print_docker)"
    len=${#ps_array[@]}

    # iterate through length of array, match against rel. paths, and print
    # container name + path (if matched )
    for ((i=0; i<len; i++)); do
        val1=${ps_array[$i]}
        out=$(path | grep $val1 | sort) # check path for matching container

        if [ -z "$out" ]; then # on no match, print just container name
                echo "$val1"
            else # on match, print container name + full path, tab-separated
                echo "$(path)" |  
                grep -v -e "/*[0-9]$" -e "-seed$" | #excl. specific containers
                grep $val1 | sort | # match to current($i) container
                awk -v p="$val1" '{print p "\t" $0}' # prepend name and print
        fi
    done
}


echo "$(result)"