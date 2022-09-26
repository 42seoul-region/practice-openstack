#!/usr/bin/env python3

import os
import configparser

conf_keystone = configparser.ConfigParser()
conf_keystone.read('/etc/keystone/keystone.conf')

# [DEFAULT]
conf_keystone['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']
conf_keystone['DEFAULT']['log_dir'] = '/var/log/keystone'

# [database]
conf_keystone['database']['connection'] = 'mysql+pymysql://{KEYSTONE_DATABASE_USER}:{KEYSTONE_DATABASE_PASSWORD}@{KEYSTONE_DATABASE_HOST}:{KEYSTONE_DATABASE_PORT}/{KEYSTONE_DATABASE_SCHEME}'.format(**os.environ)

# [credential]
conf_keystone['credential']['provider'] = 'fernet'

with open('/etc/keystone/keystone.conf', 'w') as f1:
    conf_keystone.write(f1)
