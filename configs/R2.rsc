# 2026-11-15 14:44:18 by RouterOS 7.25.1
# system id = oYpWpRW5GOD
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip address
add address=2.2.2.2 interface=lo network=2.2.2.2
add address=10.0.12.2/30 interface=ether1 network=10.0.12.0
add address=10.0.23.1/30 interface=ether2 network=10.0.23.0
/ip dhcp-client
add interface=ether1 name=client1
/routing ospf instance
add name=ospf1 router-id=2.2.2.2 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 instance=ospf1 name=backbone type=default
add area-id=0.0.0.10 instance=ospf1 name=area10 type=default
/routing ospf interface-template
add area=area10 interfaces=ether1 networks=10.0.12.0/30 type=ptp
add area=backbone interfaces=ether2 networks=10.0.23.0/30 type=ptp
add area=backbone networks=2.2.2.2/32 passive
/system identity
set name=R2
