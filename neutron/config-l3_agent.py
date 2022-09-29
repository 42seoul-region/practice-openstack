#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/neutron/l3_agent.ini')

config['DEFAULT']['interface_driver'] = 'linuxbridge'

with open('/etc/neutron/l3_agent.ini', 'w') as configfile:
    config.write(configfile)
