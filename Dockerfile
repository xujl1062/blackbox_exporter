FROM registry.haier.net/library/golang:1.13.5-alpine3.10 as build-env
# repo
RUN cp /etc/apk/repositories /etc/apk/repositories.bak
RUN echo "http://mirrors.aliyun.com/alpine/v3.10/main/" > /etc/apk/repositories
RUN echo "http://mirrors.aliyun.com/alpine/v3.10/community/" >> /etc/apk/repositories

# build
COPY . .
RUN make

ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

ARG ARCH="amd64"
ARG OS="linux"
COPY --from=build-env /build/blackbox_exporter /bin/blackbox_exporter
COPY blackbox.yml       /etc/blackbox_exporter/config.yml

EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD         [ "--config.file=/etc/blackbox_exporter/config.yml" ]
