#!/bin/bash


sudo ip link add link eth0 name eth0.100 type vlan id 100
sudo ifconfig eth0.100 172.16.100.60


sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0.100 -o wlan0 -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0.100 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "nat config finish"
