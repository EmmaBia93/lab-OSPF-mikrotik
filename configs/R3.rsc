# 2026-11-15 14:51:14 by RouterOS 7.25.1
# system id = gbLVtkXIL0H
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip address
add address=3.3.3.3 interface=lo network=3.3.3.3
add address=10.0.23.2/30 interface=ether1 network=10.0.23.0
add address=10.0.34.1/30 interface=ether2 network=10.0.34.0
/ip dhcp-client
add interface=ether1 name=client1
/routing ospf instance
add name=ospf1 router-id=3.3.3.3 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 instance=ospf1 name=backbone type=default
add area-id=0.0.0.20 instance=ospf1 name=area20 type=default
/routing ospf interface-template
add area=backbone interfaces=ether1 networks=10.0.23.0/30 type=ptp
add area=area20 interfaces=ether2 networks=10.0.34.0/30 type=ptp
add area=backbone networks=3.3.3.3/32 passive
/system identity
set name=R3
