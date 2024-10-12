#!/bin/bash

# Check if tmux is installed
if ! sys.dependencies.installed "tmux"; then
    echo "You need to install tmux to use this command."
    exit 1
fi

# Check if at least one command is provided
if [ "$#" -lt 1 ]; then
    echo "You need to provide at least one command."
    exit 1
fi

# Create a new tmux session named "my_session"
SESSION="my_session"
tmux new-session -d -s $SESSION

# Create the first window and run the first command
tmux send-keys "$1" C-m

# Create additional panes for each command
for i in $(seq 2 $#); do
    tmux split-window -t $SESSION -h
    tmux select-layout -t $SESSION tiled
    tmux send-keys "${!i}" C-m
done

# Adjust the layout to tiled
tmux select-layout -t $SESSION tiled

# Attach to the tmux session
tmux attach-session -t $SESSION
