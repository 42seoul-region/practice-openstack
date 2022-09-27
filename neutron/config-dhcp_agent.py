#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/neutron/dhcp_agent.ini')

config['DEFAULT']['interface_driver'] = 'linuxbridge'
config['DEFAULT']['dhcp_driver'] = 'neutron.agent.linux.dhcp.Dnsmasq'
config['DEFAULT']['enable_isolated_metadata'] = 'true'

with open('/etc/neutron/dhcp_agent.ini', 'w') as configfile:
    config.write(configfile)
