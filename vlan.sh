#!/usr/bin/env bash

set -e

if [ $# -lt 2 ]; then
    echo './vlan.sh <NODE_INTERNAL_IP>/CIDR <NODE_INTERNAL_BROADCAST>'
    echo 'Example: '
    echo './vlan.sh 192.168.42.1/24 255.255.255.0'
    exit 1
fi

NODE_INTERNAL_IP=$1
NODE_INTERNAL_BROADCAST=$2
NIC=$(route | grep '^default' | grep -o '[^ ]*$')

echo "Main network device is '$NIC'"

echo "Setting vlan . . ."
sudo ip link add link $NIC name vnet0 type vlan id 1
sudo ip addr add $NODE_INTERNAL_IP brd $NODE_INTERNAL_BROADCAST dev vnet0
sudo ip link set dev vnet0 up
# vnet delete
# sudo ip link delete dev vnet0

# echo "Allowing firewall for sshd in vlan . . ."
# sudo ufw allow from any to $(echo $NODE_INTERNAL_IP | awk -F'/' '{print $1}') port 22
