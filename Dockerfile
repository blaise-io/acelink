# docker build . --tag blaiseio/acestream

FROM debian:8-slim

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        curl \
        libpython2.7 \
        net-tools \
        python-minimal \
        python-pkg-resources \
        python-m2crypto \
        python-apsw \
        python-lxml \
    && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/acestream && \
    curl --silent "http://dl.acestream.org/linux/acestream_3.1.16_debian_8.7_x86_64.tar.gz" \
        | tar --extract --gzip --strip-components=1 -C /opt/acestream && \
    echo '/opt/acestream/lib' >> /etc/ld.so.conf && \
    /sbin/ldconfig

CMD /opt/acestream/acestreamengine --client-console
