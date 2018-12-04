#!/bin/bash

# Read secrets from .env file and create them in Swarm.

echo "Provide secret versioning, e.g. v1, v2 etc."
read -r version

# echo "Please enter the server (e.g. m1.swarm.aws): "
# read -r server

echo "Please enter t for text, f for file secrets, d for delete"
read -r mode

function add_secret_text () {
    # $1 secret name
    # $2 secret value
    # $3 server
    name=$(echo "$1" | tr "[:upper:]" "[:lower:]")
    echo "$2" | docker secret create "$name"_"$version" -
}

function add_secret_file () {
    # $1 secret name
    # $2 secret file
    # $3 server

    docker secret create "$1_$version" "$2"
}

function delete_secret () {
    # $1 secret name
    name=$(echo "$1" | tr "[:upper:]" "[:lower:]")
    docker secret rm "$name"_"$version"
}

while IFS='' read -r line || [[ -n "$line" ]]; do

    key=$(echo "${line}" | awk -F"=" '{ print $1}')
    value=$(echo "${line}" | awk -F"=" '{ print $2}')

    if [[ $mode == "t" ]]; then
        # echo "key: $key" "value: $value"
        add_secret_text "$key" "$value"
    elif [[ $mode == "d" ]]; then
        delete_secret "$key"
    else
        # echo "key: $key" "value: $value"
        add_secret_file "$key" "$value"
    fi

done < "$1"

# $1 file to read from