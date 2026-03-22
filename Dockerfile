# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 apteno/alpine-jq:2024-05-12 AS acestream

ARG DEST_FILE=acestream.tgz \
    TMP_DIR=/tmp/acestream \
    DOWNLOAD_URL="https://download.acestream.media/linux/acestream_3.2.3_ubuntu_18.04_x86_64_py3.8.tar.gz" \
    CHECKSUM="bf45376f1f28aaff7d9849ff991bf34a6b9a65542460a2344a8826126c33727d"

RUN mkdir -p "$TMP_DIR" && \
    wget --no-verbose -O "$DEST_FILE" "$DOWNLOAD_URL" && \
    echo "$CHECKSUM $DEST_FILE" | sha256sum -cs && \
    tar --extract --gzip --directory "$TMP_DIR" --file "$DEST_FILE"

FROM --platform=linux/amd64 ubuntu:focal

RUN mkdir /opt/acestream

COPY --from=acestream "/tmp/acestream" "/opt/acestream/"

ARG DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# Install system packages.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked\
    --mount=type=cache,target=/var/lib/apt,sharing=locked\
    --mount=type=tmpfs,target=/tmp\
    apt-get update;\
    apt-get install -yq --no-install-recommends python3.8 libpython3.8 python3-pip;\
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
