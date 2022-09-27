#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/neutron/plugins/ml2/linuxbridge_agent.ini')

config['linux_bridge']['physical_interface_mappings'] = 'provider:{PROVIDER_INTERFACE_NAME}'.format(**os.environ)

config['vxlan']['enable_vxlan'] = 'true'
config['vxlan']['local_ip'] = os.environ['OVERLAY_INTERFACE_IP_ADDRESS']
config['vxlan']['l2_population'] = 'true'

config['securitygroup']['enable_security_group'] = 'true'
config['securitygroup']['firewall_driver'] = 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'

with open('/etc/neutron/plugins/ml2/linuxbridge_agent.ini', 'w') as configfile:
    config.write(configfile)
