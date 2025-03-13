#!/bin/bash

decode_file(){
    base64 -d /etc/app/.txt.b64 > /etc/app/.txt
}

encode_file(){
    base64 /etc/app/.txt > /etc/app/.txt.b64 
    rm /etc/app/.txt
}

#            1      2      3     4      5       6       7       8        9         10
passwords=("DEMO" "Q4OS" "MX" "Void" "Bodhi" "antiX" "Solus" "NixOS" "Alpine" "Endeavour")

# Password check
read -p "Please enter the password for next level (or type 'stop' to exit the game): " password



decode_file

curr_level=$(sed -n '2p' /etc/app/.txt)
curr_level=$(( curr_level + 1 ))

encode_file

# if [[ $curr_level -eq 9 ]]; then
#     echo "You've reached the realm of happiness. You're the ultimate G.O.A.T"
#     echo "Thanks! for playing"
#     echo "Made with love by WLUG"
#     echo "The password to end the game is stop."
#     echo "You may now exit by either pressing Ctrl + D or typing 'exit' (without quotes)."
# fi

if [[ $password == "stop" ]]; then
    echo "You may now exit by either pressing Ctrl + D or typing 'exit' (without quotes)."
    echo "Remember! Your progress for this level will be lost"
    exit 93
fi

if [[ $curr_level -ge 0 && $curr_level -le ${#passwords[@]} && $password == "${passwords[$((curr_level))]}" ]]; then
    # sed -i "2s/.*/$curr_level/" /etc/app/.txt
    # encode_file
    echo "Password is correct. Level updated to $(( curr_level + 1 ))."
    echo "You may now exit by either pressing Ctrl + D or typing 'exit' (without quotes)."
    exit 26
else
    # encode_file
    echo "Incorrect flag! Please try again."
    exit 0
fi
