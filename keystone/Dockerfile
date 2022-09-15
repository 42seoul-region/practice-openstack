FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV KEYSTONE_DATABASE_USER=keystone
ENV KEYSTONE_DATABASE_PASSWORD=keystone_password
ENV KEYSTONE_DATABASE_SCHEME=keystone
ENV KEYSTONE_DATABASE_HOST=mariadb
ENV KEYSTONE_DATABASE_PORT=3306
ENV KEYSTONE_ADMIN_USER=admin
ENV KEYSTONE_ADMIN_PASS=keystone_admin_password
ENV KEYSTONE_ADMIN_PROJECT=admin
ENV KEYSTONE_HTTP_SCHEME=http
ENV KEYSTONE_HOST=localhost
ENV KEYSTONE_PORT=5000
ENV REGION_ID=42region

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga && \
    apt install -y keystone=2:21.0.0-0ubuntu1~cloud0 apache2=2.4.41-4ubuntu3.12

EXPOSE ${KEYSTONE_PORT}

WORKDIR /
COPY ./entrypoint.sh .
ENTRYPOINT  ./entrypoint.sh
