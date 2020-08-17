#!/usr/bin/env bash

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

function validate_args_env { 
    local envtarget=$1;

    valid_args=("prod" "dev")
    if [[ ! " ${valid_args[@]} " =~ " $envtarget " ]]; then
        valid_values=$(join_by ' , ' ${valid_args[@]})
        echo "warning: target \"$envtarget\" is not valid. Valid values are: $valid_values"
        exit 2;
    fi
    echo "Provisioning target \"$envtarget\" is valid."
}

## global variable for waitime
waittime=5

function command_looping { 
    local commands=("$@")
    local EXIT_STATUS=0
    for cmd in "${commands[@]}";
    do
        echo "Executing $cmd"
        
        ( $cmd ) || EXIT_STATUS=$?
        if [ $EXIT_STATUS -gt 0 ]; then
            echo "[ERROR!! $EXIT_STATUS ]"
            exit $EXIT_STATUS;
        fi

        echo "............... sleeping $waittime seconds ..............."
        sleep $waittime
    done

    echo $EXIT_STATUS
}

## IN WORKS
function reverse_array { 
    local array=("$@")
    min=0
    max=$(( ${#array[@]} -1 ))

    while [[ min -lt max ]]
    do
        # Swap current first and last elements
        x="${array[$min]}"
        array[$min]="${array[$max]}"
        array[$max]="$x"

        # Move closer
        (( min++, max-- ))
    done

    echo "${array[@]}"
}