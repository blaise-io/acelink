# syntax=docker/dockerfile:experimental
FROM ubuntu:bionic

# Install system packages
RUN set -ex && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        ca-certificates \
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
    wget --no-verbose --output-document acestream.tgz "https://download.acestream.media/linux/acestream_3.1.49_ubuntu_18.04_x86_64.tar.gz" && \
    echo "d2ed7bdc38f6a47c05da730f7f6f600d48385a7455d922a2688f7112202ee19e acestream.tgz" | sha256sum --check && \
    tar --extract --gzip --directory /opt/acestream --file acestream.tgz && \
    rm -rf acestream.tgz && \
    /opt/acestream/start-engine --version

# Acestream 3.1.49 install is missing library files,
# but we can grab these from a previous release.
# http://oldforum.acestream.media/index.php?topic=12448.msg26872
RUN wget --no-verbose --output-document acestream.tgz "https://download.acestream.media/linux/acestream_3.1.16_ubuntu_16.04_x86_64.tar.gz" && \
    echo "452bccb8ae8b5ff4497bbb796081dcf3fec2b699ba9ce704107556a3d6ad2ad7 acestream.tgz" | sha256sum --check && \
    tar --extract --gzip --strip-components 1 --directory /tmp --file acestream.tgz && \
    cp /tmp/lib/acestreamengine/py*.so /opt/acestream/lib/acestreamengine/ && \
    cp /tmp/lib/*.so* /usr/lib/x86_64-linux-gnu/ && \
    rm -rf tmp/* acestream.tgz

# Overwrite disfunctional Ace Stream web player with a working videojs player,
# Access at http://127.0.0.1:6878/webui/player/<acestream id>
COPY player.html /opt/acestream/data/webui/html/player.html

# Prep dir
RUN mkdir /acelink

COPY acestream.conf /opt/acestream/acestream.conf
ENTRYPOINT ["/opt/acestream/start-engine", "@/opt/acestream/acestream.conf"]

HEALTHCHECK CMD wget -q -t1 -O- 'http://127.0.0.1:6878/webui/api/service?method=get_version' | grep '"error": null'

EXPOSE 6878
EXPOSE 8621
