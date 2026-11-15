# 2026-11-15 14:42:49 by RouterOS 7.25.1
# system id = 1WmEfsk2IeH
#
/interface bridge
add name=lan
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip address
add address=1.1.1.1 interface=lo network=1.1.1.1
add address=10.0.12.1/30 interface=ether1 network=10.0.12.0
add address=192.168.10.1/24 interface=lan network=192.168.10.0
/ip dhcp-client
add interface=ether1 name=client1
/ip route
add blackhole dst-address=172.16.99.0/24
/routing ospf instance
add name=ospf1 redistribute=static router-id=1.1.1.1 version=2 vrf=main
add name=ospf1 redistribute=static router-id=1.1.1.1 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.10 instance=ospf1 name=area10 type=default
add area-id=0.0.0.10 instance=ospf1 name=area10 type=default
/routing ospf interface-template
add area=area10 interfaces=ether1 networks=10.0.12.0/30 type=ptp
add area=area10 networks=192.168.10.0/24 passive
add area=area10 networks=1.1.1.1/32 passive
add area=area10 interfaces=ether1 networks=10.0.12.0/30 type=ptp
add area=area10 networks=192.168.10.0/24 passive
add area=area10 networks=1.1.1.1/32 passive
/system identity
set name=R1
/interface bridge port
add bridge=lan interface=ether3
