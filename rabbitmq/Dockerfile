FROM rabbitmq:latest

ARG RABBIT_PASS

# Healthcheck
HEALTHCHECK --interval=3s --timeout=5s --start-period=3s --retries=30 \
CMD rabbitmq-diagnostics -q ping

COPY config-rabbitmq.sh config-rabbitmq.sh
RUN chmod +x config-rabbitmq.sh
RUN sh ./config-rabbitmq.sh

EXPOSE 4369 5671 5672 15691 15692 25672

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rabbitmq-server"]