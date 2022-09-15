FROM mariadb:10.9

HEALTHCHECK \
    --interval=1s \
    --timeout=1s \
    --start-period=1s \
    --retries=20 \
    CMD [ "healthcheck.sh", "--su=mysql", "--connect", "--innodb_initialized" ]

COPY ./custom-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/custom-entrypoint.sh" ]
CMD [ "mariadbd" ]