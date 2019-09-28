#!/bin/sh

export PATH="$PATH:/usr/local/bin"

# TODO: Only when we started it.
osascript -e 'quit app "VLC"' &> /dev/null

if docker ps &> /dev/null; then

    if docker top acelink--ace-stream-server &> /dev/null; then
        echo "Stop server"
        docker stop acelink--ace-stream-server &> /dev/null || true
    fi

fi
