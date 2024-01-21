#!/bin/bash

if ! using_zsh; then
    info_text "Installing dependencies..."
    sudo apt-get install xclip
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get install speedtest
fi

if mac; then
    info_text "Installing dependencies..."
    brew install xclip jq
    brew tap teamookla/speedtest
    brew install speedtest --force
fi

info_text "Installing python dependencies..."
pip3 install -r requirements.txt
