FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV OPENSTACK_ADMIN_PROJECT=admin
ENV OPENSTACK_ADMIN_ROLE=admin
ENV OPENSTACK_SERVICE_PROJECT=service
ENV OPENSTACK_DEBUG=false

ENV KEYSTONE_ADMIN_USER=keystone
ENV KEYSTONE_ADMIN_PASS=keystone_admin_password

ENV PLACEMENT_USER=placement
ENV PLACEMENT_PASS=placement_password

ENV KEYSTONE_PUBLIC_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_ADMIN_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_INTERNAL_ENDPOINT=http://keystone-server:5000

ENV PLACEMENT_PUBLIC_ENDPOINT=http://placement-api-server:8778
ENV PLACEMENT_ADMIN_ENDPOINT=http://placement-api-server:8778
ENV PLACEMENT_INTERNAL_ENDPOINT=http://placement-api-server:8778

ENV REGION_ID=42region

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga
RUN apt install -y placement-api=1:7.0.0-0ubuntu1~cloud0 apache2=2.4.41-4ubuntu3.12 python3-pip python3-pymysql

# Install pip and OpenStack client
RUN pip install python-openstackclient

EXPOSE 8778

# Copy configuration files
WORKDIR /
COPY . .

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget -O - http://localhost:8778 >/dev/null 2>/dev/null || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
