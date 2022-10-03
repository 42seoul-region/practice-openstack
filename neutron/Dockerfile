FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga
RUN apt install -y --fix-missing \
                    iproute2 net-tools \
                    neutron-server=2:20.2.0-0ubuntu1~cloud0 \
                    neutron-linuxbridge-agent=2:20.2.0-0ubuntu1~cloud0 \
                    neutron-l3-agent=2:20.2.0-0ubuntu1~cloud0 \
                    neutron-dhcp-agent=2:20.2.0-0ubuntu1~cloud0 \
                    neutron-metadata-agent=2:20.2.0-0ubuntu1~cloud0 \
                    neutron-plugin-ml2=2:20.2.0-0ubuntu1~cloud0 \
                    apache2=2.4.41-4ubuntu3.12 \
                    python3-pip

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
