#!/bin/bash

# Function to reset (delete the .txt.b64 file)
reset() {
    if [ -f "./-/bind_it/.txt.b64" ]; then
        rm -f "./-/bind_it/.txt.b64"
        echo "Game Reset!"
    else
        echo "Error: Game not able to reset"
    fi
}

# Function to stop Docker containers starting with "war"
stop_it() {
    containers=$(docker ps -a --filter "name=^/warg" -q)
    if [ -n "$containers" ]; then
        docker stop $containers &> /dev/null
        docker rm -f $containers &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Game Stopped!"
        else
            echo "Error: Failed to stop some containers."
        fi
    else
        echo "No 'war' containers found."
    fi
}

# To run as sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to the root user using 'sudo su' and then run the script."
    exit 1
fi

# Parse flags
while getopts ":rs" opt; do
    case $opt in
        r)
            reset
            exit 0
            ;;
        s)
            stop_it
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Check gcc
#!/bin/bash

# # Check if gcc is installed
# if command -v gcc &> /dev/null; then
#     echo "gcc is installed."
# else
#     echo "gcc is not installed. Installing gcc..."
#     sudo apt update &> /dev/null
#     sudo apt install -y gcc &> /dev/null
#     if [ $? -eq 0 ]; then
#         echo "gcc was installed successfully."
#     else
#         echo "Error: gcc installation failed."
#         exit 1
#     fi
# fi


# Ensure the main script is executable
if [ ! -x "./-/start.sh" ]; then
    echo "The main script ./-/start.sh is not executable. Adding execute permissions."
    chmod +x ./-/start.sh
fi

./-/start.sh
