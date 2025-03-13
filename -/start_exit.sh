#!/bin/bash

# Function to start the level
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
EXIT_CODE=$?
update_level() {
    decode_file
    curr_level=$(sed -n '2p' $SCRIPT_DIR/bind_it/.txt)
    if [[ $? -ne 0 ]]; then
        echo "Error reading level from file."
        exit 1
    fi
    curr_level=$(( curr_level + 1 ))
    sed -i "2s/.*/$curr_level/" $SCRIPT_DIR/bind_it/.txt
    if [[ $? -ne 0 ]]; then
        echo "Error updating level in file."
        exit 1
    fi
    encode_file
}

decode_file() {
    if [[ -f $SCRIPT_DIR/bind_it/.txt.b64 ]]; then
        base64 -d $SCRIPT_DIR/bind_it/.txt.b64 > $SCRIPT_DIR/bind_it/.txt
        if [[ $? -ne 0 ]]; then
            echo "Error decoding file."
            exit 1
        fi
    else
        echo "Encoded file does not exist."
        exit 1
    fi
}

encode_file() {
    base64 $SCRIPT_DIR/bind_it/.txt > $SCRIPT_DIR/bind_it/.txt.b64
    if [[ $? -ne 0 ]]; then
        echo "Error encoding file."
        exit 1
    fi
    rm $SCRIPT_DIR/bind_it/.txt
}

start_Level() {
    local user=$1
    local curr_l=$2
    local container_name="warg$(( curr_l + 1 ))"

    if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "$container_name"; then
        echo "Container '$container_name' already exists. Starting and attaching to it..."
        docker start "$container_name" &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error starting container."
            exit 1
        fi
        if [ $(( curr_l + 1 )) -ne 9 ]; then
            docker exec --hostname "$user" --user root -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="$SCRIPT_DIR/bind_it",target=/etc/app -it "$container_name" /bin/bash
        else
            docker exec --hostname "$user" --user user1 -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="$SCRIPT_DIR/bind_it",target=/etc/app -it "$container_name" /bin/sh
        fi
    else
        if [ $(( curr_l + 1 )) -ne 9 ]; then
            docker run --hostname "$user" --user root -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="$SCRIPT_DIR/bind_it",target=/etc/app -it --name "$container_name" ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg$(( curr_l + 1 )) /bin/bash -c "cd /home/wlug && /bin/bash" 
        else
            docker run --hostname "$user" --user user1 -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="$SCRIPT_DIR/bind_it",target=/etc/app -it --name "$container_name" ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg$(( curr_l + 1 )) /bin/sh -c "cd ~ && /bin/sh"
        fi
    fi

    EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 26 ]]; then
        update_level
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <curr_level>"
    exit 1
fi

start_Level "$1" "$2"

# Check the exit status of the last command (start_Level)
if [ $EXIT_CODE -ne 93 ]; then
    docker rm -f warg$(( $2 + 1 )) &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Container exited successfully."
    else
        echo "Error removing container."
    fi
    $SCRIPT_DIR/start.sh
else
    containers=$(docker ps -a --filter "name=^/warg" -q)
    if [ -n "$containers" ]; then
        docker rm -f $containers &> /dev/null
        if [[ $? -eq 0 ]]; then
            echo "Game Stopped!"
        else
            echo "Error: Failed to stop some containers."
        fi
    else
        echo "No 'warg' containers found."
    fi
fi

