#!/bin/bash

clear

# Global variable for curr_level
curr_level=-1

# To run as sudo
# if [ "$(id -u)" -ne 0 ]; then
#     echo "This script must be run as root. Please switch to the root user using 'sudo su' and then run the script."
#     exit 1
# fi

# Determine the script's directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Check for internet connectivity
check_Internet() {
    if ping -c 2 google.com > /dev/null 2>&1; then
        echo "Internet is working! Great."
        return 0
    else
        return 1
    fi
}

# Determine OS type
get_OS() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "kali" ]]; then
            echo "Kali"
        elif [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]]; then
            echo "Ubuntu"
        elif [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
            echo "Debian"
        elif [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID_LIKE" == *"rhel"* ]]; then
            echo "RHEL"
        elif [[ "$ID" == "fedora" ]]; then
            echo "Fedora"
        elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
            echo "Arch"
        else
            echo "Unknown"
        fi
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "MacOS"
    else
        echo "Unknown"
    fi
}

# Restart Docker based on OS
restart_Docker() {
    local os_type=$(get_OS)
    
    case "$os_type" in
        "MacOS")
            if brew services restart docker > /dev/null 2>&1; then
                echo "Docker was successfully restarted using brew!"
                return 0
            fi
            ;;
        "Ubuntu"|"Debian"|"RHEL"|"Fedora"|"Arch"|"Kali")
            if systemctl restart docker; then
                echo "Docker was successfully restarted"
                return 0
            fi
            ;;
        *)
            echo "Unsupported OS. Cannot restart Docker automatically."
            return 1
            ;;
    esac
    
    return 1
}

# Check for Docker and install if needed
get_Docker() {
    # Check if Docker exists
    if docker images > /dev/null 2>&1; then
        echo "Docker already exists"
        return 0
    fi
    
    # Try to restart Docker
    if restart_Docker; then
        return 0
    fi
    
    echo "Docker is not installed. Attempting installation..."
    
    local os_type=$(get_OS)
    local install_status=1
    
    case "$os_type" in
        "Kali")
            echo "Installing Docker for Kali Linux..."
            sudo apt update && sudo apt install -y docker.io
            install_status=$?
            clear
            ;;
        "Ubuntu"|"Debian")
            echo "Installing Docker for $os_type..."
            sudo apt update && sudo apt install -y docker.io
            install_status=$?
            clear
            ;;
        "RHEL")
            echo "Installing Docker for $os_type..."
            sudo yum install -y docker
            install_status=$?
            clear
            ;;
        "Fedora")
            echo "Installing Docker for $os_type..."
            sudo dnf install -y docker
            install_status=$?
            clear
            ;;
        "Arch")
            echo "Installing Docker for $os_type..."
            sudo pacman -S --noconfirm docker
            install_status=$?
            clear
            ;;
        "MacOS")
            echo "Installing Docker for MacOS..."
            brew install --cask docker
            install_status=$?
            clear
            ;;
        *)
            # Fallback to snap for unknown distributions
            echo "Unknown distribution, trying snap install..."
            sudo snap install docker
            install_status=$?
            clear
            ;;
    esac
    
    if [ $install_status -eq 0 ]; then
        echo "Docker installation successful!"
        # Start Docker service
        if systemctl start docker &> /dev/null || service docker start &> /dev/null; then
            echo "Docker service started."
        fi
        return 0
    else
        echo "Docker installation failed. Please install manually or rerun the script."
        return 1
    fi
}

# Get username and store for further use
get_User(){
    while true; do
        read -p "Please enter your name (Ex: First_Last): " username
        len=${#username}
        if [ $len -eq 0 ]; then
            echo "Username cannot be empty. Please enter a valid username."
        else
            break
        fi
    done
    clear

    touch "$SCRIPT_DIR/bind_it/.txt"
    declare -A d
    d[USERNAME]=$username
    d[CURR_LEVEL]=$curr_level
    echo "${d[USERNAME]}" >> "$SCRIPT_DIR/bind_it/.txt"
    echo "${d[CURR_LEVEL]}" >> "$SCRIPT_DIR/bind_it/.txt"

    base64 "$SCRIPT_DIR/bind_it/.txt" > "$SCRIPT_DIR/bind_it/.txt.b64"
    rm "$SCRIPT_DIR/bind_it/.txt"
}

# Get game images   
pull_Levels(){
    clear
    echo "Patience is the key! Pulling Levels..."
    echo "Till then open your cheatsheets, relax and have a sip of commands."
    echo "
    ----------------------------
    Basic Linux Commands Cheatsheet
    ----------------------------
    - ls              : List directory contents
    - cd [dir]        : Change directory
    - pwd             : Print working directory
    - mkdir [dir]     : Create a new directory
    - rmdir [dir]     : Remove an empty directory
    - rm [file]       : Remove a file
    - cp [src] [dst]  : Copy files or directories
    - mv [src] [dst]  : Move or rename files or directories
    - touch [file]    : Create a new file or update the timestamp
    - cat [file]      : Concatenate and display file content
    - grep [pattern] [file] : Search for a pattern in a file
    - find [dir] -name [pattern] : Find files by name
    - chmod [mode] [file] : Change file permissions
    - chown [user]:[group] [file] : Change file owner and group
    - ps              : Display currently running processes
    - top             : Display system tasks and resource usage
    - kill [pid]      : Terminate a process by PID
    - df              : Display disk space usage
    - du [dir]        : Estimate file space usage
    - free            : Display memory usage
    - man [command]   : Display the manual for a command
    - sudo [command]  : Execute a command with superuser privileges
    - curl [url]      : Transfer data from or to a server
    - unzip [file.zip]: Extract files from a zip archive
    - zip [file.zip] [files] : Create a zip archive
    - tar -cvf [archive.tar] [files] : Create a tar archive
    - tar -xvf [archive.tar] : Extract files from a tar archive
    ----------------------------
    "
    
    # Start pulling Docker images in the background
    (
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg0 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg1 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg2 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg3 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg4 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg5 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg6 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg7 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg8 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg9 &> /dev/null
        docker pull ghcr.io/walchand-linux-users-group/wildwarrior44/wargame_finals:warg10 &> /dev/null
        # Create a file to indicate completion
        touch /tmp/docker_pulls_complete
    ) &

    # Save the process ID of the background job
    pull_pid=$!

    # Define the spinner characters
    spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    
    # Position cursor at the bottom of the cheatsheet
    echo -e "\n\nConnect to a stable internet connection for best experience."
    
    # Run the spinner animation until the background process completes
    i=0
    while kill -0 $pull_pid 2>/dev/null && [ ! -f /tmp/docker_pulls_complete ]; do
        echo -ne "\rPulling game levels ${spinner[$i]} "
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.2
    done
    
    # Clean up the temp file
    rm -f /tmp/docker_pulls_complete
    
    # Show completion message
    echo -e "\rGame levels downloaded successfully! ✓        "
    sleep 1
}


if [ -f "$SCRIPT_DIR/bind_it/.txt.b64" ]; then
    # get_Docker
    decoded_content=$(base64 -d "$SCRIPT_DIR/bind_it/.txt.b64")
    username=$(echo "$decoded_content" | sed -n '1p')
    curr_level=$(echo "$decoded_content" | sed -n '2p')
    echo $curr_level
else
    clear
    get_Docker
    get_User
    pull_Levels
fi

# Call start_exit.sh with parameters
clear

echo "Welcome to CTF Demo Level $(( curr_level + 1 ))" 
if [ ! -x "$SCRIPT_DIR/start_exit.sh" ]; then
    # echo "The main script ./-/start.sh.x is not executable. Adding execute permissions."
    chmod +x $SCRIPT_DIR/start_exit.sh
fi

"$SCRIPT_DIR/start_exit.sh" "$username" "$curr_level"