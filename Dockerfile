# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:focal

ENV LC_ALL="C.UTF-8" \
    LANG="C.UTF-8" \
    DOWNLOAD_URL="http://download.acestream.media/linux/acestream_3.1.75rc4_ubuntu_18.04_x86_64_py3.8.tar.gz" \
    CHECKSUM="6d4947dffad58754a6de725d49f8f9a574931c13c293eb4c9c3f324e93ba8356"

# Install system packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked\
    --mount=type=cache,target=/var/lib/apt,sharing=locked\
    --mount=type=tmpfs,target=/tmp\
    set -ex;\
    apt-get update;\
    apt-get install -yq --no-install-recommends ca-certificates python3.8 libpython3.8 python3-pip wget;\
    echo "wget here";\
    mkdir -p /opt/acestream;\
    wget --no-verbose --output-document /opt/acestream/acestream.tgz $DOWNLOAD_URL;\
    echo "$CHECKSUM /opt/acestream/acestream.tgz" | sha256sum --check;\
    tar --extract --gzip --directory /opt/acestream --file /opt/acestream/acestream.tgz;\
    rm /opt/acestream/acestream.tgz;\
    cat /opt/acestream/requirements.txt;\
    pip3 install -r /opt/acestream/requirements.txt;\
    /opt/acestream/start-engine --version;

# Overwrite disfunctional Ace Stream web player with a working videojs player,
# Access at http://127.0.0.1:6878/webui/player/<acestream id>
COPY player.html /opt/acestream/data/webui/html/player.html
COPY acestream.conf /opt/acestream/acestream.conf

# Prep dir serving m3u8 files.
RUN mkdir /acelink

EXPOSE 6878
EXPOSE 8621

ENTRYPOINT ["/opt/acestream/start-engine", "@/opt/acestream/acestream.conf"]
HEALTHCHECK CMD wget -q -t1 -O- 'http://127.0.0.1:6878/webui/api/service?method=get_version' | grep '"error": null'
