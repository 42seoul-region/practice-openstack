FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV OPENSTACK_ADMIN_PROJECT=admin
ENV OPENSTACK_ADMIN_ROLE=admin
ENV OPENSTACK_DEBUG=false

ENV KEYSTONE_ADMIN_USER=keystone
ENV KEYSTONE_ADMIN_PASS=keystone_admin_password

ENV KEYSTONE_HTTP_SCHEME=http
ENV KEYSTONE_HOST=localhost
ENV KEYSTONE_PORT=5000

ENV GLANCE_USER=glance
ENV GLANCE_PASS=glance_password

ENV GLANCE_HTTP_SCHEME=http
ENV GLANCE_HOST=localhost
ENV GLANCE_PORT=9292

ENV REGION_ID=42region

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga
RUN apt install -y glance=2:24.1.0-0ubuntu1~cloud0 apache2=2.4.41-4ubuntu3.12 python3-pip

# Install pip and OpenStack client
RUN pip install python-openstackclient

EXPOSE ${GLANCE_PORT}

# Copy configuration files
WORKDIR /
COPY . .

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget --no-verbose --tries=1 --spider ${GLANCE_HTTP_SCHEME}://${GLANCE_HOST}:${GLANCE_PORT}/v3/ || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
