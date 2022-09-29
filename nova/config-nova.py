#!/usr/bin/env python3

import os
import configparser
import socket

conf_nova = configparser.ConfigParser()
conf_nova.read('/etc/nova/nova.conf')

# [api_database]
conf_nova['api_database']['connection'] = 'mysql+pymysql://{NOVA_DATABASE_USER}:{NOVA_DATABASE_PASSWORD}@{NOVA_DATABASE_HOST}:{NOVA_DATABASE_PORT}/{NOVA_API_DATABASE_SCHEME}'.format(**os.environ)
# [database]
conf_nova['database']['connection'] = 'mysql+pymysql://{NOVA_DATABASE_USER}:{NOVA_DATABASE_PASSWORD}@{NOVA_DATABASE_HOST}:{NOVA_DATABASE_PORT}/{NOVA_DATABASE_SCHEME}'.format(**os.environ)

# [DEFAULT]
conf_nova['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']
# conf_nova['DEFAULT']['transport_url'] = 'rabbit://{RABBIT_USER}:{RABBIT_PASS}@{RABBIT_HOST}/'.format(**os.environ)\
conf_nova['DEFAULT']['transport_url'] = 'rabbit://openstack:{RABBIT_PASS}@{HOST_RABBITMQ}:5672/'.format(**os.environ)
# conf_nova['DEFAULT']['my_ip'] = os.environ['NOVA_EXTERNAL_HOST']
conf_nova['DEFAULT']['my_ip'] = socket.gethostbyname(os.environ['HOST_NOVA'])

# [api]
conf_nova['api']['auth_strategy'] = 'keystone'

# [keystone_authtoken]
conf_nova['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}'.format(**os.environ)
conf_nova['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
conf_nova['keystone_authtoken']['memcached_servers'] = '{HOST_MEMCACHED}:11211'.format(**os.environ)
conf_nova['keystone_authtoken']['auth_type'] = 'password'
conf_nova['keystone_authtoken']['project_domain_name'] = 'Default'
conf_nova['keystone_authtoken']['user_domain_name'] = 'Default'
conf_nova['keystone_authtoken']['project_name'] = 'service'
conf_nova['keystone_authtoken']['username'] = os.environ['NOVA_USER']
conf_nova['keystone_authtoken']['password'] = os.environ['NOVA_PASS']

# [neutron]
# This section depends on Neutron
conf_nova['neutron']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
conf_nova['neutron']['auth_type'] = 'password'
conf_nova['neutron']['project_domain_name'] = 'default'
conf_nova['neutron']['user_domain_name'] = 'default'
conf_nova['neutron']['region_name'] = os.environ['REGION_ID']
conf_nova['neutron']['project_name'] = 'service'
conf_nova['neutron']['username'] = os.environ['NEUTRON_USER']
conf_nova['neutron']['password'] = os.environ['NEUTRON_PASS']
conf_nova['neutron']['service_metadata_proxy'] = 'true'
conf_nova['neutron']['metadata_proxy_shared_secret'] = os.environ['METADATA_SECRET']

config['vnc']['enabled'] = 'true'
config['vnc']['server_listen'] = '$my_ip'
config['vnc']['server_proxyclient_address'] = '$my_ip'

# [glance]
conf_nova['glance']['api_servers'] = '{GLANCE_INTERNAL_ENDPOINT}'.format(**os.environ)

# [oslo_concurrency]
conf_nova['oslo_concurrency']['lock_path'] = '/var/lib/nova/tmp'

# [placement]
conf_nova['placement']['region_name'] = os.environ['REGION_ID']
conf_nova['placement']['project_domain_name'] = 'Default'
conf_nova['placement']['project_name'] = 'service'
conf_nova['placement']['auth_type'] = 'password'
conf_nova['placement']['user_domain_name'] = 'Default'
conf_nova['placement']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3'.format(**os.environ)
conf_nova['placement']['username'] = os.environ['PLACEMENT_API_USER']
conf_nova['placement']['password'] = os.environ['PLACEMENT_API_PASS']

with open('/etc/nova/nova.conf', 'w') as f1:
    conf_nova.write(f1)
