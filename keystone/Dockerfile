FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install packages (Apache2, Python3.9.14-1)
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y cloud-archive:yoga && \
    apt install -y apache2=2.4.41-4ubuntu3.12 python3-pip python3-pymysql

# Install packages (keystone-yoga)
RUN apt install -y keystone=2:21.0.0-0ubuntu1~cloud0

# Copy configuration files
COPY config-keystone.py config.py
COPY entrypoint-keystone.sh entrypoint.sh
RUN chmod +x config.py entrypoint.sh

EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/v3/

# Run entrypoint
ENTRYPOINT ["./entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
