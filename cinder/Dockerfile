FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install packages (Apache2, Python3.9.14-1)
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga && \
    apt install -y apache2=2.4.41-4ubuntu3.12 python3-pip python3-pymysql

# Install packages (cinder-yoga)
RUN apt install -y cinder-api cinder-scheduler

# Install pip and OpenStack client
RUN pip install python-openstackclient

EXPOSE 8776

# Copy configuration files
COPY config-cinder.py config.py
COPY entrypoint-cinder.sh entrypoint.sh
RUN chmod +x config.py entrypoint.sh

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD wget -O http://localhost:8776 >/dev/null 2/dev/null

ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
