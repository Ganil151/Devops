#### CLOUD-R1
```c
interface serial0/0/0
description connected to ISP-R1
ip address 200.0.0.1 255.255.255.252
no shutdown
clock rate 64000
```
#### ISP-R1
SET-UP Username & Password & SSH Encryption 
```c
enable password cisco
service password-encryption
username cisco password cisco


ip domain-name finishline.com
no ip domain-lookup


ip ssh version 2
ip ssh authentication-retries 3
crypto key generate rsa general-keys modulus 1024


line console 0
password cisco
login
exec-timeout 15 0
exit

line vty 0 15
login local
transport input ssh
access-class 2 in 
exit 

banner motd #!!!! UNAUTHORIZED ACCESS IS PROHIBITED !!!!#
do wr
```
Access List
```c
ip nat inside source list 1 interface Serial0/0/0 overload 

logging buffered 51200

access-list 1 permit ip 192.168.0.0 0.0.255.255
access-list 1 permit ip 10.0.0.0 0.255.255.255

ip route 0.0.0.0 0.0.0.0 200.0.0.1 
```
Setup Cloud Link
```c
interface se0/0/0 
description Connection to Cloud 
ip address 200.0.0.2 255.255.255.252
ip nat outside
no shutdown
```
Configure Inside Interface
```c
interface gigabitEthernet0/1/0
description link to CTL-MLSW
ip address 10.10.1.1 255.255.255.0
ip nat inside 
no shutdown 
```
#### Central-MLSW
SET-UP Username & Password & SSH Encryption 
```c
enable password cisco
service password-encryption
username cisco password cisco


ip domain-name finishline.com
no ip domain-lookup


ip ssh version 2
ip ssh authentication-retries 3
crypto key generate rsa general-keys modulus 1024


line console 0
password cisco
login
exec-timeout 15 0
exit

line vty 0 15
login local
transport input ssh
access-class 2 in 
exit 

banner motd #!!!! UNAUTHORIZED ACCESS IS PROHIBITED !!!!#
do wr
```
Routing Configurations
```c
ip routing 
ip route 0.0.0.0 0.0.0.0 10.10.100.2
logging buffered 51200
ntp server 10.10.3.7

interface gigabitEthernet1/1/1
description link to ISP-R1
no switchport 
ip address 10.10.100.1 255.255.255.0
no shutdown
exit
```
VTP 
```c
vtp domain finishline.com
vtp mode server 
vtp version 2
do wr
```
VLANS Configurations
```c
Vlan 2
name Finishline-AP
exit

Vlan 3
name Guest-AP
exit

Vlan 10
name Voice-IPH
exit

Vlan 20
name Data-PC
exit

Vlan 30
name Office-A-PR
exit

Vlan 40
name Server
exit

do write
```
Setup Vlan Interfaces ( SVIs)
```c
interface gigabitEthernet1/0/1
description link to WL-SW
switchport mode trunk
switchport trunk allowed vlan 2,3
switchport nonegotiate
no shutdown 
exit
````

```c
interface gigabitEthernet1/0/2
description link to DATA-SW
switchport mode trunk 
switchport trunk allowed vlan 10,20,30
switchport nonegotiate
no shutdow
exit
```

```c
interface GigabitEthernet1/0/3 
description link to DMZ-SW 
switchport mode trunk 
switchport trunk allowed vlan 40
switchport nonegotiate
no shutdown
exit
```
<font color="#ffff00">Configure Spanning Tree Protocol ( STP )</font>
```c
spanning-tree mode rapid-pvst
spanning-tree vlan 2,3,10,20,30,40 priority 4096
do write memory
```
<font color="#ffff00">Open Shortest Path First ( OSPF )</font>
```c
router ospf 1 
network 192.168.2.0 0.0.0.255 area 0
network 10.2.5.0 0.0.0.255 area 0
network 192.168.5.0 0.0.0.255 area 0
network 192.168.3.0 0.0.0.255 area 0 
network 192.168.5.0 0.0.0.255 area 0 
network 192.168.8.0 0.0.0.255 area 0
network 10.10.3.0 0.0.0.255 area 0
network 10.10.100.0 0.0.0.255 area 0
exit
do write memory
```
<font color="#ffff00">IP Address & DHCP ----------------></font>
```c
interface Vlan 2
description Finishline-AP
ip address 192.168.2.1 255.255.255.0
no shutdown
exit
ip dhcp pool Finishline-AP
network 192.168.2.0 255.255.255.0
default-router 192.168.2.1
dns-server 10.10.3.7
exit
ip dhcp excluded-address 192.168.2.1 192.168.2.20

interface Vlan 3
description Guest-AP
ip address 10.2.5.1 255.255.255.0
no shutdown
exit
ip dhcp pool Guest-AP
network 10.2.5.0 255.255.255.0
default-router 10.2.5.1
dns-server 10.10.3.7
exit
ip dhcp excluded-address 10.2.5.1 10.2.5.20

interface Vlan 10
description Voice-IPH
ip address 192.168.5.1 255.255.255.0
no shutdown
exit
ip dhcp pool Voice-IPH
network 192.168.5.0 255.255.255.0
default-router 192.168.5.1
dns-server 10.10.3.7
option 150 ip 192.168.5.1
exit
ip dhcp excluded-address 192.168.5.1 192.168.5.20

interface Vlan 20
description Data-PC
ip address 192.168.3.1 255.255.255.0
no shutdown
exit
ip dhcp pool Data-PC
network 192.168.3.0 255.255.255.0
default-router 192.168.3.1
dns-server 10.10.3.7
exit
ip dhcp excluded-address 192.168.3.1 192.168.3.20
do wr
```
<font color="#ffff00">Set Static IP Address Printer --------></font>
```c
interface Vlan 30
description Office-A-PR
ip address 192.168.8.1 255.255.255.0
ip nat inside
no shutdown
exit
ip dhcp excluded-address 192.168.8.1 192.168.8.20
do wr 
```
<font color="#ffff00">Set Static IP DMZ-SW ---------------></font>
```c
ip route 10.10.3.0 255.255.255.0 10.10.100.2
interface Vlan 40
description Servers
ip address 10.10.3.1 255.255.255.0
no shutdown
exit

do write memory
```
<font color="#ffff00">Protect DHCP </font>
```c
ip dhcp snooping 
ip dhcp snooping vlan 2,3,10,20,30,40
```
IP Routing 
<font color="#ffff00">> Only if fully configuring a STATIC NETWORK</font>
```c
ip route 192.168.2.0 255.255.255.0 vlan 2
ip route 10.2.5.0 255.255.255.0 vlan3
ip route 192.168.5.0 255.255.255.0 vlan10
ip route 192.168.3.0 255.255.255.0 vlan20
ip route 192.168.6.0 255.255.255.0 vlan30
ip route 192.168.7.0 255.255.255.0 vlan40
ip route 192.168.9.0 255.255.255.0 vlan50
ip route 192.168.10.0 255.255.255.0 vlan60
ip route 192.168.11.0 255.255.255.0 vlan65
ip route 192.168.8.0 255.255.255.0 vlan70
ip route 10.10.4.0 255.255.255.0 vlan96
ip route 10.10.5.0 255.255.255.0 vlan97
ip route 10.10.8.1 255.255.255.0 vlan98
ip route 10.10.6.1 255.255.255.0 vlan99
```
Passive Interfaces
><font color="#ffff00">Consider marking additional VLANs as passive if they do not need OSPF neighbor relationships. </font>
```c
passive-interface vlan 10 
passive-interface vlan 20 
passive-interface vlan 30 
passive-interface vlan 40 
passive-interface vlan 50 
passive-interface vlan 60 
passive-interface vlan 65 
passive-interface vlan 70 
passive-interface vlan 96 
passive-interface vlan 97 
passive-interface vlan 98 
passive-interface vlan 99
```
<font color="#ffff00">Assign IPv6 Addresses to Vlan Interfaces</font>

| VLAN    | IPv4 Subnet      | IPv6 Prefix      |     |
| ------- | ---------------- | ---------------- | --- |
| VLAN 10 | 192.168.5.0/26   | 2001:db8:10::/64 |     |
| VLAN 20 | 192.168.3.0/26   | 2001:db8:20::/64 |     |
| VLAN 30 | 192.168.5.64/26  | 2001:db8:30::/64 |     |
| VLAN 40 | 192.168.3.64/26  | 2001:db8:40::/64 |     |
| VLAN 50 | 192.168.5.128/26 | 2001:db8:50::/64 |     |
| VLAN 60 | 192.168.3.128/26 | 2001:db8:60::/64 |     |
| VLAN 65 | 192.168.3.192/26 | 2001:db8:65::/64 |     |
| VLAN 70 | 192.168.8.0/24   | 2001:db8:70::/64 |     |
<font color="#ffff00">Global IPv6 Prefix Assignments</font>

| VLAN    | IPv6 Prefix        | Description      |
| ------- | ------------------ | ---------------- |
| VLAN 10 | `2001:db8:10::/64` | MGMT-Voice       |
| VLAN 20 | `2001:db8:20::/64` | MGMT-PC          |
| VLAN 30 | `2001:db8:30::/64` | REP-Voice        |
| VLAN 40 | `2001:db8:40::/64` | REP-PC           |
| VLAN 50 | `2001:db8:50::/64` | Office-A-Voice   |
| VLAN 60 | `2001:db8:60::/64` | Office-A-PC      |
| VLAN 65 | `2001:db8:65::/64` | Office-A-Laptop  |
| VLAN 70 | `2001:db8:70::/64` | Office-A-Printer |
Verify Configuration 
```c
show ipv6 route
show ipv6 neighbors
show ipv6 dhcp binding
show ipv6 interface vlan10
```
TELE-R1
```c
interface gigabitEthernet1/1/2
description connection to TELE-R1
switchport mode trunk
switchport trunk allowed vlan 2,3,10,20,30,40
no shutdown 
exit
do write memory
```
Clean-Up Used Ports
```c
interface range gigabitEthernet1/0/2-4
no ip address
shutdown
interface range gigabitEthernet1/0/8-24
no ip address
shutdown
interface range gigabitEthernet1/1/1-2
no ip address
shutdown
```
Storm Control
```c
interface range gigabitEthernet1/0/1-24
storm-control ?
storm-control broadcast level 10.00
exit 
do wr
```
#### Wire-SW
Set Vlans
```c
Vlan 2
name Finishline-AP
exit

Vlan 3
name Guest-AP
exit

spanning-tree mode rapid-pvst
spanning-tree vlan 2,3 priority 32768
```

```c
vtp domain finishline.com
vtp mode client 
```
Interface Configuration
```c
interface gigabitEthernet0/1
description link to CTL-MLSW
switchport mode trunk
switchport trunk allowed vlan 2,3
switchport nonegotiate
no shutdown
exit
```
Access Points for Wireless VLAN
```c
interface fastEthernet0/1
description link to Finishline-AP
switchport mode access 
switchport access vlan 2
spanning-tree portfast
spanning-tree bpduguard enable
no shutdown
exit
do wr
interface fastEthernet0/2
description link to Guest-AP
switchport mode access 
switchport access vlan 3
spanning-tree portfast
spanning-tree bpduguard enable
no shutdown
exit
do wr
```
Clean-Up Used Ports
```c
interface range fastEthernet 0/3-24
shutdown
interface gigabitEthernet0/2
shutdown
```
#### Data-SW 
Set Vlans
```c
Vlan 10
name Voice-IPH
exit

Vlan 20
name Data-PC
exit

Vlan 30
name Office-A-PR
exit

spanning-tree mode rapid-pvst
spanning-tree vlan 10,20,30 priority 32768
```

```c
vtp domain finishline.com
vtp mode client
```
Trunk to Central-ML-SW
```c
interface gig0/1
description connected to CTL-MLSW
switchport mode trunk
switchport trunk allowed vlan 10,20,30
switchport nonegotiate
no shutdown
exit
do wr
```
Access Ports
```c
interface fa0/1
description connected to MGMT-IPH and MGMT-PC
switchport mode access
switchport access vlan 20
switchport voice vlan 10
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/2
description connected to REP-IP-PH and REP-PC
switchport mode access
switchport access vlan 20
switchport voice vlan 10
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/3
description connected to Office-A-IPH and Office-A-PC
switchport mode access
switchport access vlan 20
switchport voice vlan 10
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/4
description connected to Office-A-LP
switchport mode access
switchport access vlan 20
spanning-tree portfast
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/5
description Connected to Office-A-PR
switchport mode access
switchport access vlan 30
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit
do wr
```

Clean-Up Used Ports
```c
interface range fastEthernet 0/6-24
shutdown
interface gigabitEthernet0/2
shutdown
```
#### DMZ-SW
Set Vlans
```c
Vlan 40
name Server
exit
```

```c
vtp domain finishline.com
vtp mode client
```
Trunking to Central-ML-SW
```c
interface gig0/1
description connected to CTL-MLSW
switchport mode trunk
switchport trunk allowed vlan 40
switchport nonegotiate
no shutdown
exit
```

```c
spanning-tree mode rapid-pvst
spanning-tree vlan 40 priority 32768
do wr

```
Access Ports
```c
interface fa0/1
description link to Email-SR
switchport mode access
switchport access vlan 40
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/2
description link to FTP-SR
switchport mode access
switchport access vlan 40
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/3
description link to DNS-SR
switchport mode access
switchport access vlan 40
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown
exit

interface fa0/4
description link to WEB-SR
switchport mode access
switchport access vlan 40
spanning-tree portfast 
spanning-tree bpduguard enable
no shutdown 
exit 
do wr
```
Static IP Addresses for Each Server

| **Server**       | **VLAN** | **IP Address** | **Subnet Mask** | **Default Gateway** |
| ---------------- | -------- | -------------- | --------------- | ------------------- |
| **Email Server** | 90       | 10.10.3.10     | 255.255.255.0   | 10.10.3.1           |
| **FTP Server**   | 90       | 10.10.3.11     | 255.255.255.0   | 10.10.3.1           |
| **DNS Server**   | 90       | 10.10.3.7      | 255.255.255.0   | 10.10.3.1           |
| **Web Server**   | 90       | 10.10.3.12     | 255.255.255.0   | 10.10.3.1           |

Clean-Up Used Ports
```c
interface range fastEthernet0/5-24
shutdown
interface gigabitEthernet0/2
shutdown
```
Save Config on FTP
![[SaveConfigFTP_S1.png]]
![[SaveConfigFTP_S2.png]]
![[SaveConfigFTP_S3.png]]
![[SaveConfigFTP_S2.0.png]]
Setup Email
![[SaveConfigEmail.png]]
![[SaveConfigEmail1.png]]
#### TELE-R1
```c
enable password cisco
banner motd #UNAUTHORIZED ACCESS IS PROHIBITED !!!!#
no ip domain-lookup
service password-encryption
username cisco password cisco
ip domain-name finishline.com
crypto key generate rsa general-keys modulus 1024
line console 0
password cisco
login
exec-timeout 15 0
exit
ip ssh version 2
line vty 0 15
login local
transport input ssh
access-class 2 in 
exit 
do wr



ip routing 
interface GigabitEthernet0/0/0
description link to CTL-MLSW
ip address 10.10.2.2 255.255.255.0
no shutdown
exit
ip route 0.0.0.0 0.0.0.0 10.10.2.1
interface Ethernet0/1/0
description link to DATA-SW
no shutdown
exit 
do write memory


interface Ethernet0/1/0.2
encapsulation dot1q 2
description Finishline-AP
ip address 192.168.2.1 255.255.255.0
ip nat inside
ip helper-address 10.10.3.7
no shutdown
exit
ip dhcp pool Finishline-AP
network 192.168.2.0 255.255.255.0
default-router 192.168.2.1
dns-server 10.10.3.7
exit
ip dhcp excluded-address 192.168.2.1 192.168.2.10
do write memory

interface Ethernet0/1/0.3
encapsulation dot1q 3
description Guest-AP
ip address 10.2.5.1 255.255.255.0
ip nat inside
ip helper-address 10.10.3.7
no shutdown
exit
ip dhcp pool Guest-AP
network 10.2.5.0 255.255.255.0
default-router 10.2.5.1
dns-server 10.10.3.7
exit
ip dhcp excluded-address 10.2.5.1 10.2.5.10
do write memory

------------------------------------------------------

interface Ethernet0/2/0.10 
encapsulation dot1q 10 
ip address 192.168.5.1 255.255.255.0
ip nat inside
description MGMT-Voice 
ip helper-address 10.10.3.7 
no shutdown 

telephony-service 
max-ephones 3 
max-dn 3 
ip source-address 192.168.5.1 port 2000 
auto assign 2 to 4 
auto assign 1 to 3 

ephone-dn 1
number 54010

ephone 1
mac-address 0001.6361.E151
type 7960
button 1:1

ip dhcp pool MGMT-Voice 
network 192.168.5.0 255.255.255.0 
default-router 192.168.5.1 
dns-server 10.10.3.7
option 150 ip 192.168.5.1
ip dhcp excluded-address 192.168.5.1 192.168.5.10


interface Ethernet0/2/0.20 
encapsulation dot1Q 20 
ip address 192.168.3.1 255.255.255.0
ip nat inside
description MGMT-PC 
ip helper-address 10.10.3.7 
no shutdown
ip dhcp pool MGMT_PC
network 192.168.3.0 255.255.255.0
default-router 192.168.3.1
dns-server 10.10.3.7
ip dhcp excluded-address 192.168.3.1 192.168.3.10

-----------------------------------------

interface Ethernet0/2/0.30
encapsulation dot1Q 30
ip address 192.168.6.1 255.255.255.0
ip nat inside
description REP-Voice
ip helper-address 10.10.3.7
no shutdown

telephony-service
max-ephones 3
max-dn 3
ip source-address 192.168.6.1 port 3000
auto assign 6 to 8
auto assign 5 to 7

ephone-dn 2
number 54020

ephone 2
mac-address 0060.7095.2EEC
type 7960
button 1:2

ip dhcp pool REP_Voice 
network 192.168.6.0 255.255.255.0 
default-router 192.168.6.1 
dns-server 10.10.3.7
option 150 ip 192.168.6.1
ip dhcp excluded-address 192.168.6.1 192.168.6.10


interface Ethernet0/2/0.40 
encapsulation dot1Q 40 
ip address 192.168.4.1 255.255.255.0 
ip nat inside
description REP-PC  
ip helper-address 10.10.3.7 
no shutdown
ip dhcp pool REP_PC 
network 192.168.4.0 255.255.255.0 
default-router 192.168.4.1 
dns-server 10.10.3.7
ip dhcp excluded-address 192.168.4.1 192.168.4.10

-----------------------------------------

interface Ethernet0/2/0.50
encapsulation dot1Q 50
ip address 192.168.7.1 255.255.255.0
ip nat inside
description OfficeA-Voice 
ip helper-address 10.10.3.7
no shutdown

telephony-service
max-ephones 3
max-dn 3
ip source-address 192.168.7.1 port 4000
auto assign 10 to 12
auto assign 7 to 9

ephone-dn 3
number 54030

ephone 3
mac-address 0001.96EC.E2E6
type 7960
button 1:3
exit
ip dhcp pool OfficeA_Voice 
network 192.168.7.0 255.255.255.0 
default-router 192.168.7.1 
dns-server 10.10.3.7
option 150 ip 192.168.7.1
ip dhcp excluded-address 192.168.7.1 192.168.7.10

interface Ethernet0/2/0.60 
encapsulation dot1Q 60 
ip address 192.168.9.1 255.255.255.0 
ip nat inside
description OfficeA_PC 
ip helper-address 10.10.3.7 
no shutdown
ip dhcp pool OfficeA_PC 
network 192.168.9.0 255.255.255.0 
default-router 192.168.9.1 
dns-server 10.10.3.7
ip dhcp excluded-address 192.168.9.1 192.168.9.10

-----------------------------------------

interface Ethernet0/2/0.65 
encapsulation dot1Q 65
ip address 192.168.10.1 255.255.255.0 
ip nat inside
description Office-A-Laptop 
ip helper-address 10.10.3.7 
no shutdown
ip dhcp excluded-address 192.168.10.1 192.168.10.10
ip dhcp pool Office-A-Laptop
network 192.168.10.1 255.255.255.0
default-router 192.168.10.1
dns-server 10.10.3.7


interface Ethernet0/2/0.70
encapsulation dot1Q 70
ip address 192.168.8.1 255.255.255.0 
ip nat inside
description Office-A-Printer
ip helper-address 10.10.3.7 
no shutdown
ip dhcp pool OfficeA_Printer 
network 192.168.8.0 255.255.255.0
default-router 192.168.8.1 
dns-server 10.10.3.7
ip dhcp excluded-address 192.168.8.1 192.168.8.10
do wr
```
#### Firewall 
```c
Policy Access List
```c
object-group network WAN-Networks
network-object 192.168.2.0 255.255.255.0 
network-object 10.2.5.0 255.225.255.0

object-group network DATA-Neworks
network-object 192.168.3.0 255.255.255.0
network-object 192.168.6.0 255.255.255.0
network-object 192.168.7.0 255.255.255.0
network-object 192.168.8.0 255.255.255.0
network-object 192.168.9.0 255.255.255.0
network-object 192.168.10.0 255.255.255.0
network-object 192.168.11.0 255.255.255.0

object-group network DMZ-Networks
network-object 10.10.8.0 255.255.255.0
network-object 10.10.4.0 255.255.255.0 
network-object 10.10.5.0 255.255.255.0 
network-object 10.10.6.0 255.255.255.0

access-list 101 object-group WAN-Networks permit icmp any  
access-list 101 object-group WAN-Networks permit udp any eq 67
access-list 101 object-group WAN-Networks permit udp any eq 68
access-list 101 object-group WAN-Networks permit udp any eq 53
access-list 101 object-group WAN-Networks permit tcp any eq 53
access-list 101 object-group WAN-Networks permit tcp any eq 80
access-list 101 object-group WAN-Networks permit tcp any eq 25
access-list 101 object-group WAN-Networks permit tcp any eq 20
access-list 101 object-group WAN-Networks permit tcp any eq 21

access-list 102 object-group DATA-Neworks permit icmp any 
access-list 102 object-group DATA-Neworks permit udp any eq 67
access-list 102 object-group DATA-Neworks permit udp any eq 68
access-list 102 object-group DATA-Neworks permit udp any eq 53
access-list 102 object-group DATA-Neworks permit tcp any eq 53
access-list 102 object-group DATA-Neworks permit tcp any eq 80
access-list 102 object-group DATA-Neworks permit tcp any eq 25
access-list 102 object-group DATA-Neworks permit tcp any eq 20
access-list 102 object-group DATA-Neworks permit tcp any eq 21

access-list 103 object-group DMZ-Networks permit icmp any 
access-list 103 object-group DMZ-Networks permit udp any eq 67
access-list 103 object-group DMZ-Networks permit udp any eq 68
access-list 103 object-group DMZ-Networks permit udp any eq 53
access-list 103 object-group DMZ-Networks permit tcp any eq 53
access-list 103 object-group DMZ-Networks permit tcp any eq 80
access-list 103 object-group DMZ-Networks permit tcp any eq 25
access-list 103 object-group DMZ-Networks permit tcp any eq 20
access-list 103 object-group DMZ-Networks permit tcp any eq 21
```
Policy-Map QoS-Policy
```c
class-map match-any WAN-Traffic
match access-group 101
exit

class-map match-any DATA-Traffic
match access-group 102
exit

class-map match-any DMZ-Traffic
match access-group 103
exit

policy-map QoS-Policy
class WAN-Traffic
bandwidth remaining percent 35
exit
policy-map QoS-Policy
class DATA-Traffic
bandwidth remaining percent 35
exit
policy-map QoS-Policy
class DMZ-Traffic
bandwidth remaining percent 30
exit
class class-default
fair-queue
exit
```
Apply QoS Policy to Interface
```c
interface GigabitEthernet1/1/1 
descriptiion connected to ISP-R1
service-policy output QoS-Policy

interface GigabitEthernet1/0/1 
descriptiion connected to WL-SW
service-policy output QoS-Policy

interface GigabitEthernet1/0/2 
descriptiion connected to DATA-SW
service-policy output QoS-Policy

interface GigabitEthernet1/0/3 
descriptiion connected to DMZ-SW
service-policy output QoS-Policy
```
### Test and Verify 
```c
show ip arp

show ip dhcp snooping
show ip arp inspection
show ip arp inspection statistics

show ip dhcp pool
show ip dhcp excluded-address

show lldp
show lldp neighbors
show lldp neighbors detail

show interfaces <interface-id> | include flow-control
show interfaces GigabitEthernet1/0/3 | include flow-control

show policy-map interface GigabitEthernet1/0/1  
show class-map  ! To verify the class map
show policy-map  ! To verify the policy map
```
### Definitions 
>**EIGRP (Enhanced Interior Gateway Routing Protocol)** Overview

EIGRP is an advanced distance-vector routing protocol developed by Cisco. It offers several improvements over RIP, including:

- **Faster Convergence**: EIGRP converges quickly by maintaining a topology table and using the Diffusing Update Algorithm (DUAL).
- **Scalability**: Suitable for larger networks.
- **Flexible Metric Calculation**: Uses bandwidth, delay, reliability, and load for route metrics.
- **Classless Routing**: Supports VLSM (Variable Length Subnet Masks) and CIDR (Classless Inter-Domain Routing).
>**Rapid Spanning Tree Protocol (RSTP)** 
   RSTP is an evolution of the original **Spanning Tree Protocol (STP)** defined in **IEEE 802.1D**. It  addresses the slow convergence times associated with traditional STP and provides much   **faster convergence** when network topology changes occur
- **Faster Convergence**:    
    - Traditional STP can take **30 to 50 seconds** to converge due to the listening and learning states.
    - RSTP typically converges within **milliseconds to a few seconds** by skipping the listening and learning phases for eligible ports.

- **Port Roles**: RSTP introduces new port roles to optimize the convergence process:    
    - **Root Port (RP)**: The best path to the root bridge.
    - **Designated Port (DP)**: The port on a segment that advertises the best path to the root bridge.
    - **Alternate Port**: A backup to the root port, providing rapid failover.
    - **Backup Port**: A backup to the designated port on the same segment.

- **Port States**: RSTP simplifies the port states compared to STP:    
    - **Discarding**: Equivalent to the disabled, blocking, and listening states of STP.
    - **Learning**: The port learns MAC addresses but does not forward data yet.
    - **Forwarding**: The port forwards traffic and learns MAC addresses.
    
- **Point-to-Point Links**:    
    - RSTP assumes that full-duplex links are **point-to-point**, allowing for faster transitions to forwarding states.
    
- **Proposal and Agreement Mechanism**:    
    - RSTP uses a handshake mechanism to rapidly transition ports to the forwarding state.

> **Multiple Spanning Tree Protocol (MSTP)**
   MSTP is an enhancement of RSTP that allows you to map **multiple VLANs to a single spanning tree instance (STI)**. This reduces the processing overhead associated with running a separate spanning tree for each VLAN, as is done in **Per-VLAN Spanning Tree (PVST)** or **Rapid PVST (RPVST)**.

- **Multiple Instances**:    
    - MSTP can group VLANs into **multiple spanning tree instances (MSTIs)**. For example:
        - Instance 1 can handle VLANs 10, 20, and 30.
        - Instance 2 can handle VLANs 40, 50, and 60.
        
 
 - **Reduced Resource Consumption**:    
    - Instead of having a spanning tree for every VLAN, MSTP allows you to manage multiple VLANs within a smaller number of instances, which saves CPU and memory resources.

- **Compatibility with RSTP**:    
    - MSTP is based on RSTP and retains its fast convergence properties.

- **Regions**:    
    - Switches running MSTP can be grouped into **regions** where they share the same VLAN-to-instance mapping. Each region behaves like a single switch for spanning tree purposes.
    

- **Backward Compatibility**:    
    - MSTP can interoperate with traditional STP and RSTP, making it suitable for mixed network environments.

**Comparison Table: RSTP vs. MSTP**

| Feature                      | **RSTP (802.1w)**                       | **MSTP (802.1s)**                     |
| ---------------------------- | --------------------------------------- | ------------------------------------- |
| **Convergence Time**         | Fast (milliseconds to seconds)          | Fast (similar to RSTP)                |
| **VLAN Support**             | Separate instance per VLAN (Rapid PVST) | Multiple VLANs per instance           |
| **Scalability**              | Limited (many instances for many VLANs) | High (fewer instances for many VLANs) |
| **Backward Compatibility**   | STP and PVST                            | STP, PVST, and RSTP                   |
| **Configuration Complexity** | Simpler for small networks              | Better for large, complex networks    |
Multiple Spanning Tree Protocol Configuration  ( MSTP )
```c
spanning-tree mode mst
spanning-tree mst configuration
name REGION 1
revision 1
instance 1 vlan 2,3 
instance 2 vlan 10,20,30,40,50,60,70 instance 3 vlan 96,97,98,99 
```
Verify
```c
show spanning-tree mst configuration
------------------------------------
show spanning-tree mst
```

**Unicast Storm Control Cisco**

Unicast storm control is a feature on Cisco switches that monitors and regulates the amount of unicast traffic flowing into a port. When the traffic exceeds a configured threshold, the switch can take action to mitigate the storm, such as dropping excess packets or shutting down the port.

**Configuring Unicast Storm Control**

To configure unicast storm control on a Cisco switch, you can use the following command:

`storm-control unicast level {percentage | pps} [action {shutdown | trap}]`

- `percentage`: specifies the percentage of total available bandwidth that the controlled traffic can use.
- `pps`: specifies the rate limit in packets per second (pps).
- `action`: specifies the action to take when the threshold is exceeded:
    - `shutdown`: shuts down the port.
    - `trap`: sends a trap message to the network management system.

For example:

```c
interface Ethernet1/1
 storm-control unicast level 20
```

This configuration sets the unicast storm control threshold to 20% of the total available bandwidth.

Key Points

- Unicast storm control is most useful in Cisco 6500 and Nexus 7000 switches.
- The thresholds for broadcast, multicast, and unicast traffic are the same; you set a single threshold that applies to the sum total of controlled traffic.
- The `storm-control` command is additive; each time you enter a `storm-control` command, you are adding to the flavors or types of controlled traffic.
- Use the `ip arp timeout` command to adjust the ARP table timeout to match the aging time of the MAC address table.

Troubleshooting Unicast Flooding

Unicast flooding can occur when a switch is unable to learn the outgoing interface for a destination MAC address. To troubleshoot this issue:

1. Verify the MAC address table on the switch to ensure that the destination MAC address is learned.
2. Check the ARP table to ensure that the ARP entry for the destination IP address is present and not timed out.
3. Use the `debug` command to capture packets and analyze the traffic flow.

Real-World Scenario

In a scenario where asymmetric routing causes unicast flooding, you can use unicast storm control to mitigate the issue. For example, if a switch is receiving excessive unicast traffic from a particular VLAN, you can configure unicast storm control to drop excess packets or shut down the port when the threshold is exceeded.

Remember to carefully configure the threshold and action to ensure that the switch can still forward legitimate traffic while mitigating the storm.

**Spanning Tree Protocol (STP)**: a network protocol that prevents loops by dynamically disabling some ports on switches or bridges, creating a loop-free topology. It elects a root bridge, assigns a role and cost to each port, and blocks ports that create loops. STP prevents broadcast storms, allows redundant links, and ensures network reliability and performance.

**Storm Control**: a feature that monitors incoming traffic levels and compares them to a configured threshold, dropping traffic that exceeds the threshold to prevent network disruption. It is used to limit broadcast, multicast, and unicast traffic, and can be configured on a per-port basis. Storm Control is typically used to mitigate the effects of STP loops and prevent broadcast storms.

**LLDP (Link Layer Discovery Protocol)** is not currently enabled on the device. LLDP is a network protocol used to advertise identity and capabilities to directly connected devices, helping with topology discovery.

**Global LLDP Activation** To enable LLDP globally on the switch:
```c
configure terminal
lldp run
exit
```
**Interface-Specific LLDP Activation** If LLDP needs to be enabled only on specific interfaces:
```c
configure terminal
interface <interface-id>
lldp transmit
lldp receive
exit
```
**Flow control** is a mechanism used in Ethernet networking to manage traffic between devices. It helps prevent packet loss during periods of congestion by temporarily halting the transmission of frames when a device cannot handle the incoming traffic rate.
- **Input Flow Control**: Manages the reception of packets.
- **Output Flow Control**: Manages the sending of packets.
When **flow-control is off**, the interface does not pause traffic in case of congestion, and packets may be dropped if the buffers overflow.
- **Enabled Flow Control**: Prevents packet loss but can introduce delays in high-speed environments if not configured correctly.
- **Disabled Flow Control**: Ensures maximum throughput but can lead to packet drops in congested networks.
- Most Cisco switches have **flow control disabled by default**, as modern networks are typically designed to handle congestion using Quality of Service (QoS) and not rely on flow control.
```c
interface <interface-id>
flowcontrol receive on
flowcontrol send on
---------------------------------
interface GigabitEthernet1/0/3
flowcontrol receive on
flowcontrol send on
--------------------------------
interface <interface-id>
flowcontrol receive off
flowcontrol send off
```
**Best Practices**
- **Datacenter and High-Performance Networks**: Disable flow control and rely on QoS mechanisms to manage traffic effectively.
- **Congested or Legacy Networks**: Consider enabling flow control if devices struggle to handle traffic bursts.

**Cisco Express Forwarding (CEF)** is an advanced, highly efficient, and scalable layer-3 packet forwarding mechanism used in Cisco routers and multi-layer switches. It improves performance and ensures faster packet forwarding by using a precomputed Forwarding Information Base (FIB) and an adjacency table.
```c
show ip cef
show ip cef [network]
show adjacency
```

**Loopback interfaces** are virtual network interfaces in a router or switch. They are primarily used for testing and administrative purposes, as they provide a stable, always-up interface that isn't tied to any physical hardware. Loopback interfaces are often used for routing protocols, management, and IP reachability. In the context of your network setup, applying a loopback interface would provide a stable address for the router to use in various configurations, such as for OSPF or other routing protocols.
- **Loopback Interface**: A logical interface that is always up, and not tied to any physical hardware. This ensures the interface can be used for reliable testing or routing purposes.
- **IP Address**: The loopback interface has an IP address assigned (`192.168.100.x/32`), which is a single IP address and ensures it is used only as a management or test IP.
```c
ISP-R1# configure terminal
ISP-R1(config)# interface Loopback0
ISP-R1(config-if)# ip address 192.168.100.1 255.255.255.255
ISP-R1(config-if)# no shutdown
ISP-R1(config-if)# exit
ISP-R1(config)# end
ISP-R1# show ip interface brief
```

```c
CTL-MLSW# configure terminal
CTL-MLSW(config)# interface Loopback0
CTL-MLSW(config-if)# ip address 192.168.100.2 255.255.255.255
CTL-MLSW(config-if)# no shutdown
CTL-MLSW(config-if)# exit
CTL-MLSW(config)# end
CTL-MLSW# show ip interface brief
```

<font color="#ffff00">ARP Inspection </font>
```c
ip arp inspection vlan 2,3,10,20,30,40,50,60,65,70,96,97,98,99,999
ip arp inspection validate src-mac dst-mac ip
```