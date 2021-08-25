# syntax=docker/dockerfile:experimental
FROM debian:9-slim

# Install system packages
RUN set -ex && \
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
        sqlite3 \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/*

# Install Ace Stream
# https://wiki.acestream.media/Download#Linux
RUN mkdir -p /opt/acestream && \
    wget --quiet --output-document acetream.tgz "http://acestream.org/downloads/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz" && \
    echo "13cabf1882a730eb1558b63835512d14384688fc26b21651cfaa21e8e2ff7dda acetream.tgz" | sha256sum --check && \
    tar --extract --gzip --directory /opt/acestream --file acetream.tgz && \
    rm -rf acetream.tgz

COPY acestream.conf /opt/acestream/acestream.conf

# Overwrite non-functional Ace Stream web player with our own experimental web player,
# Access at http://127.0.0.1:6878/webui/html/player.html?id=<hash>
COPY player.html /opt/acestream/data/webui/html/player.html

CMD /opt/acestream/start-engine @/opt/acestream/acestream.conf
