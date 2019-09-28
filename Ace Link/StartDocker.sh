#!/bin/sh

image="blaiseio/acelink:1.3.0"  # TODO: Use XCode release version
port="6878"
hash=$1

export PATH="$PATH:/usr/local/bin"

# Start Docker if not running
if ! docker ps &> /dev/null; then
    open --background --hide -a Docker
    printf "Starting Docker"

    # Wait until Docker runs
    until docker ps &> /dev/null; do
        printf "."
        sleep 0.5
    done
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
    docker run -d --rm -p $port:$port --name="acelink--ace-stream-server" $image
    # Wait until Ace Stream server runs
    until curl "http://127.0.0.1:${port}/webui/api/service?method=get_version" &> /dev/null; do
        printf "."
        sleep 0.5
    done
    printf "\n"
fi
echo "Ace Stream server is running"

# Open stream in VLC
stream="http://127.0.0.1:${port}/ace/getstream?id=${hash}"
echo "Opening stream: $stream"
open -a VLC "${stream}" --args --no-video-title-show --meta-title "Ace Link ${hash::7}"
