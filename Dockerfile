# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:jammy

ENV LC_ALL="C.UTF-8" \
    LANG="C.UTF-8" \
    DOWNLOAD_URL="https://download.acestream.media/linux/acestream_3.2.3_ubuntu_22.04_x86_64_py3.10.tar.gz" \
    CHECKSUM="ad11060410c64f04c8412d7dc99272322f7a24e45417d4ef2644b26c64ae97c9"

# Install system packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked\
    --mount=type=cache,target=/var/lib/apt,sharing=locked\
    --mount=type=tmpfs,target=/tmp\
    set -ex;\
    apt-get update;\
    apt-get install -yq --no-install-recommends ca-certificates python3.10 libpython3.10 python3-pip wget;\
    mkdir -p /opt/acestream;\
    wget --no-verbose --output-document /opt/acestream/acestream.tgz $DOWNLOAD_URL;\
    echo "$CHECKSUM /opt/acestream/acestream.tgz" | sha256sum --check;\
    tar --extract --gzip --directory /opt/acestream --file /opt/acestream/acestream.tgz;\
    rm /opt/acestream/acestream.tgz;\
    python3 -m pip install --no-cache-dir -r /opt/acestream/requirements.txt;\
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
