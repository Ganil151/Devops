Routing protocols are a set of rules which are used to define an optimal route between sources and destination systems in a network. Basically routing works on the network layer of the OSI reference model.

 **<font color="#ff0000">Purpose of Routing Protocol Metrics:</font>**

 To determine the best route when multiple updates are received for the same route or we can say when various routes are learned so a router could receive routing updates from several other different routers all about the same network and it needs a mechanism to determine the best one well that’s where the metrics come into play and a metric is a numeric value and it’s different between each routing protocol it could be a small value or an immense value and routing protocol will look at the metric of all the similar route and it will use a lower metric to determine the best route so the general rule of thumb is the lower the metric the better the route and so a routing protocol will look and no compare and if it didn’t have a metric it would have all of these updates about the same network but it would not know which one to use it would have any basis to determine the best route so that’s the purpose to determine the best route.

**Routing Protocol Metrics:**
Each Possible path will be assigned as a ‘metric’ value by the routing protocol which indicates how preferred the path is. Always the lowest metric value is preferred. Distance vector routers advertise to each other the networks they know about and their metrics to get to each of them.
- Link state routers advertise all the links in their area of the network to each other.
- Each router will take this information and then make independent calculations of its own best path to get to each destination.
- If the best  path to a destination is lost
- For example: because a link went down it will be removed from the routing table and replaced with the next best route.

◇ Hop count
- The number of routers between two end points
- Determined from the sending router's perspective.
 ### ◇ Maximum transmission unit (MTU)
 - The maximum allowed size of a packet, measured in bytes.
 - The standard MTU for Ethernet is 1500 bytes.
 - Packets that exceed the MTU must be fragmented into small pieces, leading to more packets, leading to slower connection.
 ##### ◇ Bandwidth
  - A measure of the speed of the network connection.
    - The speed can be measured in Kbps, Mbps, or Gbps
    ##### ◇Latency  
    - A measure of time that a packet takes to traverse a link
        - When implemented by routing protocols, the total amount of latency (or delay ) to go end to end between two points is used

- Administrative Distance ( AD )
    - The believably of a routing protocol's advertised routes.
        - Different routing protocols are considered to be more believable ( trustworthy ) than others.
    - Routers use the AD to help determine which routing protocol to use when more than one protocol is install on the router
    - The lowest AD of an advertised route will determine the protocol used
    - Common standard AD's
        - Directly connected route = 0 ( no protocol required )
        - Statically configured rout = 1 ( no protocol required )
        - E - BGP = 20
        - Internal EIGRP = 90
        - OSPF = 110
        - IS-IS = 115
        - RIP = 120
        - External EIGRP = 170
        - I- BGP = 200
        - Unknown = 255 ( not believable )

### RIP Metric Hop Count:

- RIP uses hop count as the metric.
- The maximum hop count by default is 15. Paths that are more than 15 hops away are marked as unreadable.
- RIP is typically used only in small or test environments.

| S.NO | Routing Protocol                                   | Metric           |
| ---- | -------------------------------------------------- | ---------------- |
| 1.   | Routing Information Protocol ( RIP )               | Hop count        |
| 2.   | Enhanced Interior Gateway Routing Protocol (EIGRP) | bandwidth, delay |
| 3.   | Open Shortest Path First (OSPF)                    | cost             |

Example: Router receives multiple routes over to the 10.10.10.0/24 network from both the **OSPF** and **RIP**.

You can display the Administrative Distance in the router by typing the show IP route
####  command in CLI:
> **⚠️ Missing Image**: *file:///tmp/.CFZMW2/1.png* ('file:///tmp/.CFZMW2/1.png') 

#### **Relationship between Administrative Distance and Routing Metric:**

| S.No. | Administrative distance                                                                                                 | Routing Metric                                                                                  |
| ----- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| 1.    | Administrative Distance is used to choose the distance among multiple paths learned through different routing protocols | The metric is used to choose among multiple paths learned through the same protocol             |
| 2.    | It is considered to be the first to narrow the choice down to the single best routing protocol.                         | It is considered to choose the best path or paths which <br><br>make it into the routing table. |