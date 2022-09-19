FROM mariadb:10.9

ENV KEYSTONE_DATABASE_USER=keystone
ENV KEYSTONE_DATABASE_PASSWORD=keystone_database_password
ENV KEYSTONE_DATABASE_SCHEME=keystone

ENV GLANCE_DATABASE_USER=glance
ENV GLANCE_DATABASE_PASSWORD=glance_database_password
ENV GLANCE_DATABASE_SCHEME=glance

HEALTHCHECK \
    --interval=1s \
    --timeout=1s \
    --start-period=1s \
    --retries=20 \
    CMD [ "healthcheck.sh", "--su=mysql", "--connect", "--innodb_initialized" ]

COPY ./custom-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/custom-entrypoint.sh" ]
CMD [ "mariadbd" ]
