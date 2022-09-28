#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/neutron/neutron.conf')

config['database']['connection'] = 'mysql+pymysql://{NEUTRON_DATABASE_USER}:{NEUTRON_DATABASE_PASSWORD}@{NEUTRON_DATABASE_HOST}:{NEUTRON_DATABASE_PORT}/{NEUTRON_DATABASE_SCHEME}'.format(**os.environ)

# config['DEFAULT']['transport_url'] = 'rabbit://openstack:{RABBIT_PASS}@{RABBIT_HOST}:5672/'.format(**os.environ)\
config['DEFAULT']['core_plugin'] = 'ml2'
config['DEFAULT']['service_plugins'] = 'router'
config['DEFAULT']['allow_overlapping_ips'] = 'true'
config['DEFAULT']['auth_strategy'] = 'keystone'
config['DEFAULT']['notify_nova_on_port_status_changes'] = 'true'
config['DEFAULT']['notify_nova_on_port_data_changes'] = 'true'

config['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}'.format(**os.environ)
config['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
config['keystone_authtoken']['memcached_servers'] = '{HOST_MEMCACHED}:11211'.format(**os.environ)
config['keystone_authtoken']['auth_type'] = 'password'
config['keystone_authtoken']['project_domain_name'] = 'Default'
config['keystone_authtoken']['user_domain_name'] = 'Default'
config['keystone_authtoken']['project_name'] = 'service'
config['keystone_authtoken']['username'] = os.environ['NEUTRON_USER']
config['keystone_authtoken']['password'] = os.environ['NEUTRON_PASS']

config['nova']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(**os.environ)
config['nova']['auth_type'] = 'password'
config['nova']['project_domain_name'] = 'default'
config['nova']['user_domain_name'] = 'default'
config['nova']['region_name'] = os.environ['REGION_ID']
config['nova']['project_name'] = 'service'
config['nova']['username'] = os.environ['NOVA_USER']
config['nova']['password'] = os.environ['NOVA_PASS']

config['oslo_concurrency']['lock_path'] = '/var/lib/neutron/tmp'

with open('/etc/neutron/neutron.conf', 'w') as configfile:
    config.write(configfile)
