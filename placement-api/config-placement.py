#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/placement/placement.conf')

config['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']
config['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}/v3/'.format(**os.environ)
config['placement_database']['connection'] = 'mysql+pymysql://{PLACEMENT_API_DATABASE_USER}:{PLACEMENT_API_DATABASE_PASSWORD}@{PLACEMENT_API_DATABASE_HOST}:{PLACEMENT_API_DATABASE_PORT}/{PLACEMENT_API_DATABASE_SCHEME}'.format(**os.environ)
config['api']['auth_strategy'] = 'keystone'
config['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
config['keystone_authtoken']['memcached_servers'] = '{HOST_MEMCACHED}:11211'.format(**os.environ)
config['keystone_authtoken']['auth_type'] = 'password'
config['keystone_authtoken']['project_domain_name'] = 'Default'
config['keystone_authtoken']['user_domain_name'] = 'Default'
config['keystone_authtoken']['project_name'] = 'service'
config['keystone_authtoken']['username'] = os.environ['PLACEMENT_API_USER']
config['keystone_authtoken']['password'] = os.environ['PLACEMENT_API_PASS']

with open('/etc/placement/placement.conf', 'w') as configfile:
    config.write(configfile)
