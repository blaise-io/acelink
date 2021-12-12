# syntax=docker/dockerfile:experimental
FROM ubuntu:16.04

# Install system packages
RUN set -ex && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        python2.7 \
        libpython2.7 \
        net-tools \
        python-setuptools \
        python-m2crypto \
        python-apsw \
        python-lxml \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/*

# Install Ace Stream
# https://wiki.acestream.media/Download#Linux
RUN mkdir -p /opt/acestream && \
    wget --quiet --output-document acestream.tgz "http://download.acestream.media/linux/acestream_3.1.16_ubuntu_16.04_x86_64.tar.gz" && \
    echo "452bccb8ae8b5ff4497bbb796081dcf3fec2b699ba9ce704107556a3d6ad2ad7 acestream.tgz" | sha256sum --check && \
    tar --extract --gzip --strip-components 1 --directory /opt/acestream --file acestream.tgz && \
    rm -rf acestream.tgz && \
    /opt/acestream/start-engine --version

# Overwrite disfunctional Ace Stream web player with a working videojs player,
# Access at http://127.0.0.1:6878/webui/player/<acestream id>
COPY player.html /opt/acestream/data/webui/html/player.html

# Prep dir
RUN mkdir /acelink

ENTRYPOINT ["/opt/acestream/start-engine", "@/opt/acestream/acestream.conf"]

HEALTHCHECK CMD nc -zv localhost 6878 || exit 1

EXPOSE 6878
EXPOSE 8621
