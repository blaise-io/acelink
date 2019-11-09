FROM debian:9-slim

RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
        libpython2.7 \
        net-tools \
        python-minimal \
        python-pkg-resources \
        python-m2crypto \
        python-apsw \
        python-lxml \
        sqlite3 \
        wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/*
RUN mkdir -p /opt/acestream
RUN wget -qO- "http://acestream.org/downloads/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz" | \
        tar --extract --gzip -C /opt/acestream
RUN /opt/acestream/start-engine --version

# Overwrite non-functional Ace Stream web player with our own experimental web player.
# Access at http://127.0.0.1:6878/webui/html/player.html?id=<hash>.
COPY player.html /opt/acestream/data/webui/html/player.html

CMD /opt/acestream/start-engine --client-console
