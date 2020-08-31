#!/bin/bash

# clear iptables
iptables -F
iptables -X
iptables -Z
iptables -t nat -F


#ytj address
src_host='192.168.0.59'
src_port=80
src_video_port=554

# carema address

Dst_Host='192.168.0.65' 
Dst_Port=80
Dst_video_port=554

# set ip forward
sysctl -w net.ipv4.ip_forward=1

# forward request to carema
iptables -t nat -A PREROUTING -p tcp -m tcp --dport $src_port -j DNAT --to-destination $Dst_Host:$Dst_Port
iptables -t nat -A PREROUTING -p tcp -m tcp --dport $src_video_port -j DNAT --to-destination $Dst_Host:$Dst_video_port

# ...... seems to accept the packets
#iptables -A FORWARD -p tcp -d $Dst_Host --dport $Dst_Port -j ACCEPT
#iptables -A FORWARD -p tcp -d $Dst_Host --dport $Dst_video_port -j ACCEPT


# forward the answer to client
iptables -t nat -A POSTROUTING -d 192.168.0.65/32 -p tcp -m tcp --dport $Dst_Port -j SNAT --to-source $src_host
iptables -t nat -A POSTROUTING -d 192.168.0.65/32 -p tcp -m tcp --dport $Dst_video_port -j SNAT --to-source $src_host  

# save rules
iptables-save

# show iptables
iptables -L -t nat --line-number
