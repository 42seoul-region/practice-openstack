FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG NOVA_EXTERNAL_HOST

ENV OPENSTACK_ADMIN_PROJECT=admin
ENV OPENSTACK_ADMIN_ROLE=admin
ENV OPENSTACK_SERVICE_PROJECT=service
ENV OPENSTACK_DEBUG=false

ENV KEYSTONE_ADMIN_USER=keystone
ENV KEYSTONE_ADMIN_PASS=keystone_admin_password

ENV NOVA_USER=nova
ENV NOVA_PASS=nova_password

ENV KEYSTONE_PUBLIC_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_ADMIN_ENDPOINT=http://keystone-server:5000
ENV KEYSTONE_INTERNAL_ENDPOINT=http://keystone-server:5000

ENV GLANCE_INTERNAL_ENDPOINT=http://glance-server:9292

ENV NEUTRON_INTERNAL_ENDPOINT=http://neutron-server:9696

ENV NOVA_PUBLIC_ENDPOINT=http://nova-server:8774
ENV NOVA_ADMIN_ENDPOINT=http://nova-server:8774
ENV NOVA_INTERNAL_ENDPOINT=http://nova-server:8774

ENV REGION_ID=42region

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga
RUN apt install -y nova-api=3:25.0.1-0ubuntu1~cloud0 \
                    nova-scheduler=3:25.0.1-0ubuntu1~cloud0 \
                    nova-conductor=3:25.0.1-0ubuntu1~cloud0 \
                    nova-novncproxy=3:25.0.1-0ubuntu1~cloud0 \
                    apache2=2.4.41-4ubuntu3.12 python3-pip

# Install pip and OpenStack client
RUN pip install python-openstackclient

EXPOSE 8774

# Copy configuration files
WORKDIR /
COPY . .

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget -O - http://localhost:8774 >/dev/null 2>/dev/null || exit 1

ENTRYPOINT ["./entrypoint.sh"]
# CMD nova-api & \
#     nova-scheduler & \
#     nova-conductor & \
#     nova-novncproxy & \
CMD ["apache2ctl", "-D", "FOREGROUND"]
