#!/usr/bin/env bash
#
# a script to identify any running Docker containers that use Portainer relative
# paths (./example_container:/config). Moves container data to a new host with
# a more conventional naming scheme

datapath=/data/compose
target=/mnt/data/docker

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

function copy_files {
    # process output 
    while IFS= read -r line; do
        echo "processing... $line"
        cname=$(awk '{print $1}' <<< $line) # print first column to var 
        ppath=$(awk '{print $2}' <<< $line) # second column
        #echo "$cname - $ppath" #debug
        cp -arf "$ppath" "$target"
    done <<< "$output" 
}


output="$(result)"
#echo "$output" # debug

# stop docker for file backup
systemctl mask docker.socket
systemctl stop docker.service

copy_files

systemctl unmask docker.socket
systemctl reset-failed docker.service
systemctl start docker.service