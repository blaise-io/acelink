#!/bin/sh

export PATH="$PATH:/usr/local/bin"

osascript -e 'quit app "VLC"' &> /dev/null

if docker ps &> /dev/null; then
    docker kill acelink--ace-stream-server &> /dev/null || true
fi
