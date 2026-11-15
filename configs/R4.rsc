# 2026-11-15 14:52:16 by RouterOS 7.25.1
# system id = DHTlAojLDXF
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
add address=4.4.4.4 interface=lo network=4.4.4.4
add address=10.0.34.2/30 interface=ether1 network=10.0.34.0
add address=192.168.20.1/24 interface=lan network=192.168.20.0
/ip dhcp-client
add interface=ether1 name=client1
/routing ospf instance
add name=ospf1 router-id=4.4.4.4 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.20 instance=ospf1 name=area20 type=default
/routing ospf interface-template
add area=area20 interfaces=ether1 networks=10.0.34.0/30 type=ptp
add area=area20 networks=192.168.20.0/24 passive
add area=area20 networks=4.4.4.4/32 passive
/system identity
set name=R4
/interface bridge port
add bridge=lan interface=ether3
