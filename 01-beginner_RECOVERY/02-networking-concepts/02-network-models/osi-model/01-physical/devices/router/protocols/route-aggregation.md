What is route summarization (route aggregation)?

 Route summarization :
 -- also known as route aggregation  
 -- is a method to minimize the number of 
routing tables in an IP network. It consolidates selected multiple routes into a single route advertisement. This differentiates it from flat routing, in which every routing table carries a unique entry for each route. In basic terms, a route advertisement contains information that devices can use to communicate across an IP network.

Route summarization advertises a bunch of contiguous routes from the routing table in the form of a single summarized or aggregated route. For this feature to work, two or more routes must be contiguous, i.e., adjacent or adjoining.

**Route summarization explained**
In an enterprise network, **sub-netting** is the process of lengthening the mask to create multiple smaller sub-networks, or subnets. Route summarization is the opposite process. It involves shortening the mask to include several smaller networks into one larger network address. This is why it is also known as super-netting.

As the network size increases, the number of individual networks listed in the IP route table also increases, as does packet size. **Routers** cannot effectively handle a large number of sub-networks, which leads to slowdowns, **packet losses** and even crashes. That's why it's important to reduce the number of entries in the route table, which is what route summarization accomplishes.

With route summarization, many routes are advertised with just one line in an update packet, which not only reduces the packet size, but also allows more **bandwidth** for data transfer.
> **⚠️ Missing Image**: *file:///tmp/.CFZMW2/1.png* ('file:///tmp/.CFZMW2/1.png')

Figure 1.

Partial implementation of the addressing plan developed for network with IP address 156.26.0.0: Routers A, B, C and D are access routers, and each one connects to two Class C size networks. Routers E and F are the distribution routers, and Router G is the core router. (See Figure 2 for explanation of the terminology used in this diagram).

**Why is route summarization important?**
If a router needs to advertise 50 routes, it will need 50 specific lines in its update packet. As these routes increase, the number of lines required also increases, expanding packet size and the amount of bandwidth used. That means there will be less bandwidth available for actual data transfer.

Route summarization enables multiple routes to be advertised with only one line in an update packet, reducing the packet size and leaving more bandwidth for data transfer.

Also, each time a new data flow enters a router, it must identify which interface the 
traffic  must be sent out to. For this, it must perform a lookup in its routing table. This process takes longer for large routing tables and requires more router central processing unit ( CPU ) cycles to route traffic.
Route summarization can eliminate this problem by minimizing both the time required to perform lookup and reducing the number of CPU cycles.
> **⚠️ Missing Image**: *file:///tmp/.CFZMW2/2.png* ('file:///tmp/.CFZMW2/2.png')

Figure 2.
Close up view of Distribution Router F and Access Router D from Figure 1 illustrating the terminology used.

### **Route summarization advantages**
Route aggregation offers several advantages, including the following:
- reduces the number of entries in the route table, which reduces the load on the router and network overhead for routing protocols;
- minimizes latency in a complex network, especially when many routers are involved;
- reduces or eliminates unnecessary routing updates after part of the network undergoes a change in CPU cycles topology;
- hides instability in the system behind the summary that remains valid even in the absence of summarized networks;
- saves memory since routing tables will be smaller in size;
- helps save bandwidth as there are fewer routes to advertise; and
- reduces processor workloads and saves, since there are fewer packets to process and smaller routing tables to work on.

### **Route summarization disadvantages**

#### There are two main disadvantages of route aggregation:
1. **Sub-optimal routing.** Misconfigured route summarization may result in sub-optimal routing. Route summarization may also create inconsistent routing if a network has non-contiguous sub-networks. When using summaries, the router may prefer another path where it has learned a more specific network form, which may not be the most optimal routing method.
2. **Forwarding traffic for unused networks.** If the router doesn't find a matching destination in its routing table, it will start dropping traffic, leading to data loss. Also, the summary route may cover unused networks. The router that has a summary route will forward traffic to the router that advertised the summary route.

To avoid sub-optimal or incorrect routing and to prevent routers from inaccurately advertising networks or duplicating other routers' advertisements, it's important to design networks with summarization in mind. Advance planning and leaving room for future network growth can help with the design of a scalable network that supports route summarization.

Enabling or disabling automatic route summarization :
Depending on the routing protocol, network layout and requirements, the route summarization feature can be enabled or disabled.

Different routing protocols use this feature differently. For example, to implement route summarization in I**Pv4**, Classless Inter-Domain Routing must be used. All IP addresses in the route advertisement must share identical high-order bits. The length of the prefix must not exceed 32 bits. Routing Information Protocol ( RIP ) and Enhanced Interior Gateway Routing Protocol both support route summarization. They also summarize all the contiguous networks across the network class boundaries automatically. On the other hand, Open Shortest Path First, a link-state routing protocol, does not summarize any type of routing information.
To enable automatic route summarization on RIPv2, for example, the auto-summary command must be used from the router's sub-config mode.

To disable automatic route summarization, the no auto-summary command must be used from the same mode.