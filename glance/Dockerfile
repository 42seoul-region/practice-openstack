FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install packages (Apache2, Python3.9.14-1)
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga && \
    apt install -y apache2=2.4.41-4ubuntu3.12 python3-pip python3-pymysql

# Install packages (glance-yoga)
RUN apt install -y glance=2:24.1.0-0ubuntu1~cloud0

# Install pip and OpenStack client
RUN pip install python-openstackclient

# Copy configuration files
COPY config-glance.py config.py
COPY entrypoint-glance.sh entrypoint.sh
RUN chmod +x config.py entrypoint.sh

EXPOSE 9292

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
    CMD wget -O - http://localhost:9292 >/dev/null

# Run entrypoint
ENTRYPOINT ["./entrypoint.sh"]
CMD ["glance-api", "--config-dir", "/etc/glance", "--debug"]
