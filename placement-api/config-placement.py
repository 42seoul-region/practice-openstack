#!/usr/bin/env python3

import os
import configparser

conf_placement = configparser.ConfigParser()
conf_placement.read('/etc/placement/placement.conf')

# [DEFAULT]
conf_placement['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']

# [placement_database]
conf_placement['placement_database']['connection'] = 'mysql+pymysql://{PLACEMENT_API_DATABASE_USER}:{PLACEMENT_API_DATABASE_PASSWORD}@{PLACEMENT_API_DATABASE_HOST}:{PLACEMENT_API_DATABASE_PORT}/{PLACEMENT_API_DATABASE_SCHEME}'.format(**os.environ)

# [api]
conf_placement['api']['auth_strategy'] = 'keystone'

# [keystone_authtoken]
conf_placement['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
conf_placement['keystone_authtoken']['memcached_servers'] = '{HOST_INTERNAL_MEMCACHED}:11211'.format(**os.environ)
conf_placement['keystone_authtoken']['auth_type'] = 'password'
conf_placement['keystone_authtoken']['project_domain_name'] = 'Default'
conf_placement['keystone_authtoken']['user_domain_name'] = 'Default'
conf_placement['keystone_authtoken']['project_name'] = 'service'
conf_placement['keystone_authtoken']['username'] = os.environ['PLACEMENT_API_USER']
conf_placement['keystone_authtoken']['password'] = os.environ['PLACEMENT_API_PASS']

with open('/etc/placement/placement.conf', 'w') as f1:
    conf_placement.write(f1)
