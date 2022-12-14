FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

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
RUN apt install -y --fix-missing \
        neutron-plugin-ml2=2:20.2.0-0ubuntu1~cloud0 \
        neutron-l3-agent=2:20.2.0-0ubuntu1~cloud0 \
        neutron-dhcp-agent=2:20.2.0-0ubuntu1~cloud0 \
        neutron-metadata-agent=2:20.2.0-0ubuntu1~cloud0

# Install pip and OpenStack client
RUN pip install python-openstackclient

EXPOSE 9696

# Copy configuration files
WORKDIR /
COPY . .

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget -O - http://localhost:9696 >/dev/null 2>/dev/null || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
