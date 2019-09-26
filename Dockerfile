# docker build . --squash

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
        wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/*
RUN mkdir -p /opt/acestream
RUN wget -qO- "http://acestream.org/downloads/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz" \
        | tar --extract --gzip --strip-components=1 -C /opt/acestream
RUN echo '/opt/acestream/lib' >> /etc/ld.so.conf && /sbin/ldconfig
CMD /opt/acestream/acestreamengine --client-console
