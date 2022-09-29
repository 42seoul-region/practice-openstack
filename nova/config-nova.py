#!/usr/bin/env python3

import os
import configparser
import socket

config = configparser.ConfigParser()
config.read('/etc/nova/nova.conf')

config['api_database']['connection'] = 'mysql+pymysql://{NOVA_DATABASE_USER}:{NOVA_DATABASE_PASSWORD}@{NOVA_DATABASE_HOST}:{NOVA_DATABASE_PORT}/{NOVA_API_DATABASE_SCHEME}'.format(**os.environ)
config['database']['connection'] = 'mysql+pymysql://{NOVA_DATABASE_USER}:{NOVA_DATABASE_PASSWORD}@{NOVA_DATABASE_HOST}:{NOVA_DATABASE_PORT}/{NOVA_DATABASE_SCHEME}'.format(**os.environ)

config['DEFAULT']['transport_url'] = 'rabbit://openstack:{RABBIT_PASS}@{HOST_RABBITMQ}:5672/'.format(**os.environ)
config['DEFAULT']['my_ip'] = socket.gethostbyname(os.environ['HOST_NOVA'])

config['api']['auth_strategy'] = 'keystone'
config['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}'.format(**os.environ)
config['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
config['keystone_authtoken']['memcached_servers'] = '{HOST_MEMCACHED}:11211'.format(**os.environ)
config['keystone_authtoken']['auth_type'] = 'password'
config['keystone_authtoken']['project_domain_name'] = 'Default'
config['keystone_authtoken']['user_domain_name'] = 'Default'
config['keystone_authtoken']['project_name'] = 'service'
config['keystone_authtoken']['username'] = os.environ['NOVA_USER']
config['keystone_authtoken']['password'] = os.environ['NOVA_PASS']

config['neutron']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
config['neutron']['auth_type'] = 'password'
config['neutron']['project_domain_name'] = 'default'
config['neutron']['user_domain_name'] = 'default'
config['neutron']['region_name'] = os.environ['REGION_ID']
config['neutron']['project_name'] = 'service'
config['neutron']['username'] = os.environ['NEUTRON_USER']
config['neutron']['password'] = os.environ['NEUTRON_PASS']
config['neutron']['metadata_proxy_shared_secret'] = os.environ['METADATA_SECRET']

config['vnc']['enabled'] = 'true'
config['vnc']['server_listen'] = '$my_ip'
config['vnc']['server_proxyclient_address'] = '$my_ip'

config['glance']['api_servers'] = '{GLANCE_INTERNAL_ENDPOINT}'.format(**os.environ)

config['oslo_concurrency']['lock_path'] = '/var/lib/nova/tmp'

config['placement']['region_name'] = os.environ['REGION_ID']
config['placement']['project_domain_name'] = 'Default'
config['placement']['project_name'] = 'service'
config['placement']['user_domain_name'] = 'Default'
config['placement']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3'.format(**os.environ)
config['placement']['auth_type'] = 'password'
config['placement']['username'] = os.environ['PLACEMENT_API_USER']
config['placement']['password'] = os.environ['PLACEMENT_API_PASS']

with open('/etc/nova/nova.conf', 'w') as configfile:
    config.write(configfile)
