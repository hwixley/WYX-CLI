#!/bin/bash

if ! sys.shell.zsh; then
    sys.info "Installing dependencies..."
    sudo apt-get update
    sudo apt-get -y install xclip jq csvkit
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get -y install speedtest

fi

if sys.os.mac; then
    sys.info "Installing dependencies..."
    brew update
    brew install xclip jq csvkit
    brew tap teamookla/speedtest
    brew install speedtest --force
fi

sys.info "Installing python dependencies..."
pip3 install -r requirements.txt
