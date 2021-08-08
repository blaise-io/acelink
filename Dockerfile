# syntax=docker/dockerfile:experimental
FROM debian:9-slim

# Install system packages
RUN --mount=type=cache,target=/var/cache \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/tmp \
    sed -i 's/deb http:\/\/security.debian.org/#/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        libpython2.7 \
        net-tools \
        python-minimal \
        python-pkg-resources \
        python-m2crypto \
        python-apsw \
        python-lxml \
        sqlite3

# Install Ace Stream from local mirror
ADD thirdparty/acestream_3.1.49_debian_9.9_x86_64.tar.gz /opt/acestream
COPY acestream.conf /opt/acestream/acestream.conf

# Overwrite non-functional Ace Stream web player with our own experimental web player,
# Access at http://127.0.0.1:6878/webui/html/player.html?id=<hash>
COPY player.html /opt/acestream/data/webui/html/player.html

CMD /opt/acestream/start-engine @/opt/acestream/acestream.conf
