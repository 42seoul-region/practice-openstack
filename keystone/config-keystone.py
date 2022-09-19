#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/keystone/keystone.conf')

config['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']
config['database']['connection'] = 'mysql+pymysql://{KEYSTONE_DATABASE_USER}:{KEYSTONE_DATABASE_PASSWORD}@{KEYSTONE_DATABASE_HOST}:{KEYSTONE_DATABASE_PORT}/{KEYSTONE_DATABASE_SCHEME}'.format(**os.environ)
config['credential']['provider'] = 'fernet'

with open('/etc/keystone/keystone.conf', 'w') as configfile:
    config.write(configfile)
