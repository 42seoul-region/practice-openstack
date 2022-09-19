FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV OPENSTACK_ADMIN_PROJECT=admin
ENV OPENSTACK_ADMIN_ROLE=admin
ENV OPENSTACK_DEBUG=false

ENV KEYSTONE_DATABASE_USER=keystone
ENV KEYSTONE_DATABASE_PASSWORD=keystone_database_password
ENV KEYSTONE_DATABASE_SCHEME=keystone
ENV KEYSTONE_DATABASE_HOST=mariadb
ENV KEYSTONE_DATABASE_PORT=3306

ENV KEYSTONE_ADMIN_USER=keystone
ENV KEYSTONE_ADMIN_PASS=keystone_admin_password

ENV KEYSTONE_PUBLIC_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_ADMIN_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_INTERNAL_ENDPOINT=http://keystone-server:5000

ENV REGION_ID=42region

# Install packages (keystone-yoga, Python3.9.14-1)
RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga && \
    apt install -y keystone=2:21.0.0-0ubuntu1~cloud0 apache2=2.4.41-4ubuntu3.12 python3-pip

EXPOSE 5000

# Copy configuration files
WORKDIR /
COPY . .

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/v3/ || exit 1

# Run entrypoint
ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
