FROM rabbitmq:latest

ENV RABBIT_PASS=rabbitmq_password

VOLUME "/var/lib/rabbitmq"

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
    CMD rabbitmq-diagnostics -q ping

COPY docker-entrypoint-custom.sh /usr/local/bin/docker-entrypoint-custom.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

EXPOSE 4369 5671 5672 15691 15692 25672

CMD ["docker-entrypoint-custom.sh", "rabbitmq-server"]
