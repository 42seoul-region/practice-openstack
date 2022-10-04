#!/usr/bin/env python3

import os
import configparser
import socket

conf_cinder = configparser.ConfigParser()
conf_cinder.read('/etc/cinder/cinder.conf')

# [database]
conf_cinder['database']['connection'] = 'mysql+pymysql://{CINDER_DATABASE_USER}:{CINDER_DATABASE_PASSWORD}@{CINDER_DATABASE_HOST}:{CINDER_DATABASE_PORT}/{CINDER_API_DATABASE_SCHEME}'.format(**.os.environ)

# [DEFAULT]
conf_cinder['DEFAULT']['transport_url'] = 'rabbit://openstack:{RABBIT_PASS}@{HOST_INTERNAL_RABBITMQ}:5672/'.format(**os.environ)
conf_cinder['DEFAULT']['auth_strategy'] = 'keystone'
conf_cinder['DEFAULT']['my_ip'] = socket.gethostbyname(os.environ['HOST_VLAN_CONTROLLER'])

# [keystone_authtoken]
conf_cinder['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}'.format(**os.environ)
conf_cinder['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
conf_cinder['keystone_authtoken']['memcached_servers'] = '{HOST_INTERNAL_MEMCACHED}:11211'.format(**os.environ)
conf_cinder['keystone_authtoken']['auth_type'] = 'password'
conf_cinder['keystone_authtoken']['project_domain_name'] = 'Default'
conf_cinder['keystone_authtoken']['user_domain_name'] = 'Default'
conf_cinder['keystone_authtoken']['project_name'] = 'service'
conf_cinder['keystone_authtoken']['username'] = os.environ['CINDER_USER']
conf_cinder['keystone_authtoken']['password'] = os.environ['CINDER_PASS']

# [oslo_concurrency]
conf_cinder['oslo_concurrency']['lock_path'] = '/var/lib/cinder/tmp'

with open('/etc/cinder/cinder.conf', 'w') as f1:
    conf_cinder.write(f1)
