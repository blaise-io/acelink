#!/bin/sh
set -e

port="6878"
stream="http://127.0.0.1:${port}/ace/getstream?${stream_id_param}=${hash}"

export PATH="$PATH:/usr/local/bin"
echo "Docker image: ${image}"
echo "Acestream hash: ${hash}"

# Start Docker if not running
if ! docker ps &> /dev/null; then
    printf "Starting Docker"
    open --background --hide -a Docker || exit 100

    # Wait until Docker runs
    until docker ps &> /dev/null; do (
        ((c++)) && ((c==60)) && exit 101
        printf "." && sleep 0.5
    ) done
    printf "\n"
fi
echo "Docker is running"

# Download Docker image if not available
if ! docker image inspect $image &> /dev/null; then
    echo "Pull Docker image ${image}"
    docker pull $image
fi

# Shutdown if it was still running
docker kill acelink--ace-stream-server || true

# Start Ace Stream server if not running
if ! nc -z 127.0.0.1 $port &> /dev/null; then
    printf "Starting Ace Stream server"
    container=$(docker run -d --rm -p $port:$port --name="acelink--ace-stream-server" $image)

    # Wait until Ace Stream server runs
    until curl "http://127.0.0.1:${port}/webui/api/service?method=get_version" &> /dev/null; do (
        ((c++)) && ((c==30)) && exit 102
        printf "." && sleep 0.5
    ) done
    printf "\n"
fi
echo "Ace Stream server is running"

# Some websites open acestream:// and communicate with the server directly.
if [ -z "$hash" ]; then
    echo "Booting server only..."
    exit 0
fi

echo "Verifying stream: $stream"
curl -sSq --fail $stream || exit 103

echo "Retrieving title"
sdbfile="/root/.ACEStream/sqlite/torrentstream.sdb"
title=$(docker exec $container sqlite3 $sdbfile "SELECT name FROM Torrent;")
echo "Title: $title"

echo "Creating playlist"
streamsdir="$HOME/Library/Application Support/Ace Link/streams"
streamfile="$streamsdir/${title} [${hash::7}].m3u8"
mkdir -p "${streamsdir}"

echo "#EXTM3U\n\
#EXTINF:0, Ace Link - $title [${hash::7}]\n\
$stream\n" > "$streamfile"

echo "Opening stream $stream from $streamfile"
open -a VLC "$streamfile" --args --no-video-title-show || exit 104
