FROM ubuntu:latest AS build

ARG XMRIG_VERSION='v6.18.0'
ENV DEBIAN_FRONTEND=noninteractive

RUN   apt-get update && apt-get install -y -qq git build-essential cmake libuv1-dev uuid-dev libmicrohttpd-dev libhwloc-dev libssl-dev
WORKDIR /root
RUN git clone https://github.com/xmrig/xmrig
WORKDIR /root/xmrig
RUN git checkout ${XMRIG_VERSION}
RUN mkdir build && cd build && cmake .. -DOPENSSL_USE_STATIC_LIBS=TRUE && make

FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3 python3-pip
RUN apt-get update && apt-get install -y libhwloc15
USER root
COPY docker-entrypoint.sh /usr/local/bin/
COPY baslat.py /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/baslat.py

RUN useradd -ms /bin/bash monero
USER monero
WORKDIR /home/monero
COPY --from=build --chown=monero /root/xmrig/build/xmrig /home/monero

ENTRYPOINT ["docker-entrypoint.sh"]
