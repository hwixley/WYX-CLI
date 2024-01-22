#!/bin/bash

if ! sys.shell.zsh; then
    sys.info "Installing dependencies..."
    sudo apt-get install xclip
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get install speedtest
fi

if sys.os.mac; then
    sys.info "Installing dependencies..."
    brew install xclip jq
    brew tap teamookla/speedtest
    brew install speedtest --force
fi

sys.info "Installing python dependencies..."
pip3 install -r requirements.txt
