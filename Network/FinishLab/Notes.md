# Computer Networking Models

- A **Base Transceiver Station (BTS)**: is a fixed radio transceiver in any mobile network. The BTS connects mobile devices to the network. It sends and receives radio signals to mobile devices and converts them to digital signals that it passes on the network to route to other terminals in the network or to the internet.

- A **Base Station Controller (BSC):** is a network element that controls and monitors a number of base stations and provides the interface between the cell sites and the mobile switching center.

- A **Mobile Switching Center (MSC):** is a telephone exchange that connects mobile users to other mobile networks, the public switched telephone network and other mobile users withing the same network.

- A **Gateway:** is a network node or device that connects two networks that use different transmission protocols

- A **Media Access Control(MAC):** is a network data transfer policy that determines how data is transmitted between two computer terminals through a network cable. The media access control policy involves sub-layers of the data link layer 2 in the OSI reference models.

- A **Local Area Network(LAN):** is a collection of devices connected together in one physical location, such as building, office or home. A LAN can be small or home.

- A **Metropolitan Area Network (MAN):** is a high-speed computer network that connects multiple local area networks (LAN) within a metropolitan area, such as city or region. A (MAN) is larger than a LAN, which covers a building or campus, but smaller than a WIDE AREA NETWORK (WAN)

- A **Wide Area Network(WAN):** is a telecommunications network that connects multiple locations over a large geographic area, such as offices, data centers, and cloud applications.

- A **Address Resolution Protocol (ARP):** is a communication protocol that maps IP addresses to MAC addresses on a network. ARP is essential for routing traffic to the correct device on a subnet.

- **Domain Name Server(DNS):** is when a user types a domain name into a browser, the DNS translates the request into an IP address, which is then used to locate the server that hosts the website.

## Open System Interconnection (OSI) Model

The open systems interconnection model is a conceptual model created by the International Organization for Standardization which enables diverse communication systems to communicate using standard protocols.

> **OSI Model has 7 Layers**

1. ***The Physical Layer:*** this layer includes the physical equipment involved in the data transfer, such as the cables and switches. This is also the layer where the data gets converted into a bit stream, which is a string of 1s and 0s. The physical layer of both devices must also agree on a signal convention so that the 1s can be distinguished from the 0s on both devices.

      ![Physical Layer](/Slides/osi_model_physical_layer_1.jpg)

2. **The Data Link Layer:** is very similar to the network, except the data link layer facilitates data transfer between 2 devices on the same network. The data link layer takes packets from the network layer and breaks them into smaller pieces called frames. Like the network layer, the data link layer is also responsible for flow control and error control in intra-network communication (The transport layer only does flow control and error control for inter-network communications)

      ![DataLinkLayer](/Slides/data_link_layer_osi_model.jpg)

3. **The Network Layer:** is responsible for facilitating data transfer between two different networks. If the two devices communicating are on the same network, then the network layer is unnecessary. The network layer breaks up segments from the transport layer into smaller units, called packets, on the sender's device, and reassembling these packets on the receiving device. The network layer also finds the best physical path for the data to reach its destination; this is known as routing.

      ![NetworkLayer](/Slides/osi_model_network_layer_3.jpg)

4. **The Transport Layer:** is responsible for end-to-end communication between the two devices. This includes taking data from the session layer and breaking it up into chunks called segments before sending it to layer 3. The transport layer on the receiving device is responsible for reassembling the segments into data the session layer can consume. It is also responsible for flow control and error control. Flow control determines an optimal speed of transmission to ensure that a sender with a fast connection does not overwhelm a receiver with a slow connection. The transport layer performs error control on the receiving end by ensuring that the data received is complete, and requesting a retransmission if it isn't.

      ![TransportLayer](/Slides/osi_model_transport_layer_4.jpg)

5. **The Session Layer:** is responsible for opening and closing communication between the two devices. The time between when the communication is opened and closed is known as the session. The session layer ensures that the session stays open long enough to transfer all the data being exchanged, and then promptly closes the session in order to avoid wasting resources. It also synchronizes data transfer with checkpoints. For example, if a 100 megabyte file is being transferred, the session layer could set a checkpoint every 5 megabytes. In the case of a disconnect or a crash after 52 megabytes have been transferred, the session could be resumed from the last checkpoint, meaning only 50 more megabytes of data need to be transferred.

      ![SessionLayer](/Slides/osi_model_session_layer_5.jpg)

6. **The Presentation Layer:** is primarily responsible for preparing data so that it can be used by the application layer; in other words, layer 6 makes the data presentable for applications to consume. The presentation layer is responsible for translation, encryption, and compression of data.
Two communicating devices communicating may be using different encoding methods, so layer 6 is responsible for translating incoming data into a syntax that the application layer of the receiving device can understand.
If the devices are communicating over an encrypted connection, layer 6 is responsible for adding the encryption on the sender's end as well as decoding the encryption on the receiver's end so that it can present the application layer with unencrypted, readable data.
Finally the presentation layer is also responsible for compressing data it receives from the application layer before delivering it to layer 5. This helps improve the speed and efficiency of communication by minimizing the amount of data that will be transferred.

      ![PresentationLayer](/Slides/osi_model_presentation_layer_6.jpg)

7. **The Application Layer**: is the only that directly interacts with data from the user. Software applications like web browsers and email clients rely on the application layer to initiate communications. But it should be made clear that client software applications are not part of the application layer; rather the application layer is responsible for the protocols and data manipulation that the software relies on to present meaningful data to the user.

      ![ApplicationLayer](/Slides/osi_model_application_layer_7.jpg)

## Layers of the Transmission Control Protocol(TCP) / Internet Protocol (IP) Model

TCP/IP is essential because it provides an architecture that allows for virtually instantaneous communication across all types of network media, such as copper, fiber, or wireless. It does this using the Internet Protocol Suite, which encompasses both the TCP and UDP protocols.

- The Transmission Control Protocol(TCP) is a communication protocol responsible for ensuring that data is transferred reliably and in order between the two devices.

- On the hand, IP is the layer protocol responsible for routing network traffic.

- TCP is connection-oriented protocol that establishes a connection between two nodes before transmitting any data. All data sent over a TCP connection is checked for accuracy and retransmitted until the data is received correctly. This reliability makes TCP well-suited for applications that require a hight degree of error-checking and for large data transfers. And also, TCP operates at the lowest level of the OSI model, transmitting data in segments, which are then reassembled into whole frames by the receiver.

- TCP also provides congestion control, which helps prevent network congestion by regulating the rate at which data is sent.

- Additionally, TCP can control the flow of data, allowing data to be sent at different rates depending on the application's needs.

- **The TCP/IP Model Layer:**
  
  - **Application Layer:**
    This is the topmost layer which indicates the application and programs that utilize the TCP/IP model for communicating with the user through applications and various tasks performed by the layer, including data representation for the applications executed by the user and forwards it to transport layer.
    The application layer maintains a smooth connection between the application and user for data exchange and offers various features as remote handling of the system, email services, etc

    - ***Protocols Layers:***

    - **HTTP** : HyperText Transfer Protocol is used for accessing the information available on the internet.

    - **SMTP** : Simple Mail Transfer Protocol, assigned the task of handling email-related steps and issues.

    - **FTP** : This is the standard protocol that oversees the transfer of files over the network channel.
    ![AL](/Slides/applicationLayer.jpg)

  - **Transport Layer:**
    This layer is responsible for establishing the connection between the sender and the receiver device and also performs the task of dividing the data from the application layer into packets which are then used to create sequences.
    It also performs the task of maintaining the data, i.e., to transmitted without error, and controls the data flow rate over the communication channel for smooth transmission of data.

    - ***Protocols Layer:***

    - **TCP : Transmission Control Protocol** is responsible fo the proper transmission of segments over the communication channel.

    - **UDP : User Datagram Protocol** is responsible for identifying errors, and other tasks during the transmission of information. UDP maintains various fields for data transmission such as:
      - **Source Port Address** : This port is responsible for designing the application that makes up the message to be transmitted.

      - **Destination Port Address** : This port receives the message sent from the sender side.

      - **Total Length** : The total number of bytes of the user datagram.

      - **Checksum** : Used for error detection of the message at the destination side.
      ![TransportLayer](/Slides/TransportLayer.jpg)

  - **Internet Layer:**
    The Internet Layer performs the task of controlling the transmission  the data over the network modes and enacts protocols related to the various steps related to the transmission of data over the channel, which is in the form of packets sent by the previous layer.
    This layer performs many important functions in the TCP/IP model, some of which are:

    1. It is responsible for specifying the path that the data packets will use fo transmission;

    2. This layer is responsible for providing IP addresses to the system for the identification matters over the network channel.

    - ***Protocols Layer:***

    - **IP :** This protocol assigns your device with a unique address; the IP address is also responsible for routing the data over the communication channel.

    - **ARP :** This protocol refers to the Address Resolution Protocol that is responsible for finding the physical address using the IP address
    ![InternetLayer](/Slides/InternetLayer.jpg)
  
  - **Network Access Layer:**
    This layer is the combination of data-link and physical layer, where it is responsible for maintaining the task of sending and receiving data in raw bits i.e., in binary format over the physical communication modes in the network channel.
    - It uses the physical address of the system for mapping the path of transmission over the network channel
    - Till this point in this tutorial on what is TCP/IP model, you understood the basic idea behind the model and details about its layers, now compare the model with another network model.
    ![NetworkAccessLayer](/Slides/jkNetworkLayer.jpg)

### Network Command Line

- ping : Test the reachability of a host an IP network. exp: ping google.com

- traceroute (or tracert) : Displays the route and measures transit delays of packets across an IP network. exp: tracert -h 9 google.com

- ipconfig(Windows) or ifconfig(Linux) : is a command line tool that displays the TCP/IP network configuration of the network adapters.
  - IPv6 (Internet Protocol version 6) is the most recent version of the Internet Protocol (IP), which is used to identify and locate computer on networks and route traffic across the network, it also uses 128-bit addresses
  - IPv4 (Internet Protocol version 4) is the fourth version of the Internet Protocol(IP) and one of the core protocols of standards-based internetworking methods in the Internet and other packet-switched networks, and it also uses 32-bit addresses limit
  - Subnet Mask is a 32-bit number used in IP networking to divide an IP address into two parts: the network address and the host address
  - Default Gateway: is the IP address of the router or modem/router combo in your home or small office that your computer connects to on your network
  - DHCP(Dynamic Host Configuration Protocol) is a network management protocol used on IP networks. It automatically assigns IP addresses and other network configuration parameters to devices on the network, allowing them to communicate effectively
  - ipconfig /flushdns
  - ipconfig /displaydns

- nslookup : queries the Domain Name System (DNS) to obtain domain name or IP address mapping 

- netstat (Network Statics): display network connections, routing tables, interface statistics, masquerade connections, and multicast memberships.
  - -n : displays addresses and port numbers in numerical form.
  - -o : displays the owning process ID associated with each connection 
  - -a : displays all connections and listening ports
  - -p : filter for a specific protocol (TCP or UDP)

- Address Resolution Protocol (ARP) : displays and modifies the IP-to_Physical address translation tables.
  - Types of entries:
    - Dynamic : entry is created automatically when a device sends out a broadcast message out on the network.
    - Static : entry is where someone manually enter an IP to MAC address association using the ARP command line utility

- whois : queries database that store registered users or assignees of an Internet resource, such as domain name or an IP address block. 

- nmap : a network scanning tool used to discover hosts and services on a computer network by sending packets and analyzing the responses.
[HackerJoe](https://youtu.be/JHAMj2vN2oU?t=339)

- tcp : captures and analyzes network packets.

- route : displays and modifies the IP routing table. 

- ICMP (Internet Control Message Protocol) is a supporting protocol in the internet protocol suite. It is primarily used by network devices, such as routers, to send error messages and operational information indicating success or failure when communicating with another IP address. 

Research:
getmac
ipconfig
IP address
IPV4 address
What are the different classes of IPV4 address and how do they differ from each other,
what is IP protocol?
ICMP protocol?
network command line
