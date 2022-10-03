FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga
RUN apt install -y openstack-dashboard=4:22.1.0-0ubuntu2~cloud0 apache2=2.4.41-4ubuntu3.12 python3-pip

EXPOSE 80

# Copy configuration files
WORKDIR /

# Copy configuration files
COPY config-local_settings.sh config.sh
COPY entrypoint-horizon.sh entrypoint.sh
RUN chmod +x config.sh entrypoint.sh

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget -O - http://localhost:80 >/dev/null 2>/dev/null || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
