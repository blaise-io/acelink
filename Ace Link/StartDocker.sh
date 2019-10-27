#!/bin/sh
set -e

port="6878"
stream="http://127.0.0.1:${port}/ace/getstream?id=${hash}"

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

echo "Verifying stream: $stream"
curl -sS --fail $stream || exit 103

echo "Opening stream: $stream"
open -a VLC "${stream}" --args --no-video-title-show --meta-title "Ace Link ${hash::7}" || exit 104
