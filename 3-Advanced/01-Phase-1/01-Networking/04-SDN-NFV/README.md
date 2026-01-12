# Software-Defined Networking (SDN) and Network Function Virtualization (NFV)

Advanced networking paradigms for cloud-native and virtualized environments. This section covers SDN controllers, OpenFlow, NFV orchestration, and programmable network infrastructure.

## 🎯 Learning Objectives

- Understand SDN architecture and OpenFlow protocol
- Deploy and configure SDN controllers
- Implement Network Function Virtualization (NFV)
- Design intent-based networking solutions
- Develop network automation with APIs

## 🌐 SDN Fundamentals

### SDN Architecture

```
┌─────────────────────────────────────────┐
│          Application Layer              │
│  [Network Apps] [Orchestration] [APIs] │
└─────────────┬───────────────────────────┘
              │ Northbound APIs
┌─────────────▼───────────────────────────┐
│           Control Layer                 │
│  [SDN Controller] [Network OS] [Logic] │
└─────────────┬───────────────────────────┘
              │ Southbound APIs (OpenFlow)
┌─────────────▼───────────────────────────┐
│        Infrastructure Layer             │
│  [Switches] [Routers] [Access Points]  │
└─────────────────────────────────────────┘
```

### OpenFlow Protocol

**OpenFlow Switch Configuration:**
```bash
# Open vSwitch configuration
ovs-vsctl add-br br0
ovs-vsctl set bridge br0 protocols=OpenFlow13
ovs-vsctl set-controller br0 tcp:192.168.1.100:6633

# Add ports to bridge
ovs-vsctl add-port br0 eth1
ovs-vsctl add-port br0 eth2

# View OpenFlow configuration
ovs-ofctl show br0
ovs-ofctl dump-flows br0
```

## 🎮 SDN Controllers

### OpenDaylight Controller

**Installation and Setup:**
```bash
# Download and install OpenDaylight
wget https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/karaf/0.15.3/karaf-0.15.3.tar.gz
tar -xzf karaf-0.15.3.tar.gz
cd karaf-0.15.3

# Start controller
./bin/karaf

# Install features
feature:install odl-restconf-all
feature:install odl-l2switch-switch-ui
feature:install odl-dluxapps-applications
```

**REST API Usage:**
```python
#!/usr/bin/env python3
import requests
import json

class OpenDaylightAPI:
    def __init__(self, controller_ip, username='admin', password='admin'):
        self.base_url = f"http://{controller_ip}:8181/restconf"
        self.auth = (username, password)
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    
    def get_topology(self):
        url = f"{self.base_url}/operational/network-topology:network-topology"
        response = requests.get(url, auth=self.auth, headers=self.headers)
        return response.json()
    
    def add_flow(self, node_id, table_id, flow_id, flow_config):
        url = f"{self.base_url}/config/opendaylight-inventory:nodes/node/{node_id}/flow-node-inventory:table/{table_id}/flow/{flow_id}"
        response = requests.put(url, auth=self.auth, headers=self.headers, json=flow_config)
        return response.status_code == 200

# Usage example
controller = OpenDaylightAPI("192.168.1.100")
topology = controller.get_topology()
print(json.dumps(topology, indent=2))
```

### ONOS Controller

**ONOS Installation:**
```bash
# Install ONOS using Docker
docker run -t -d -p 8181:8181 -p 8101:8101 -p 5005:5005 -p 830:830 --name onos onosproject/onos

# Access ONOS CLI
ssh -p 8101 onos@localhost

# ONOS CLI commands
onos> apps -a -s
onos> devices
onos> links
onos> flows
```

**ONOS Application Development:**
```java
// Simple ONOS application
@Component(immediate = true)
public class SimpleForwardingApp {
    
    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected CoreService coreService;
    
    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected FlowRuleService flowRuleService;
    
    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected PacketService packetService;
    
    private ApplicationId appId;
    private PacketProcessor processor = new SimplePacketProcessor();
    
    @Activate
    protected void activate() {
        appId = coreService.registerApplication("org.example.simple-forwarding");
        packetService.addProcessor(processor, PacketProcessor.director(2));
        log.info("Simple Forwarding App Started");
    }
    
    @Deactivate
    protected void deactivate() {
        packetService.removeProcessor(processor);
        log.info("Simple Forwarding App Stopped");
    }
    
    private class SimplePacketProcessor implements PacketProcessor {
        @Override
        public void process(PacketContext context) {
            // Packet processing logic
            InboundPacket pkt = context.inPacket();
            Ethernet ethPkt = pkt.parsed();
            
            if (ethPkt.getEtherType() == Ethernet.TYPE_IPV4) {
                // Handle IPv4 packets
                installRule(context, pkt.receivedFrom().port());
            }
        }
    }
}
```

### Ryu Controller

**Ryu Simple Switch:**
```python
#!/usr/bin/env python3
from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_3
from ryu.lib.packet import packet, ethernet, ether_types

class SimpleSwitch13(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(SimpleSwitch13, self).__init__(*args, **kwargs)
        self.mac_to_port = {}

    @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, ev):
        datapath = ev.msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # Install table-miss flow entry
        match = parser.OFPMatch()
        actions = [parser.OFPActionOutput(ofproto.OFPP_CONTROLLER,
                                        ofproto.OFPCML_NO_BUFFER)]
        self.add_flow(datapath, 0, match, actions)

    def add_flow(self, datapath, priority, match, actions, buffer_id=None):
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                           actions)]
        if buffer_id:
            mod = parser.OFPFlowMod(datapath=datapath, buffer_id=buffer_id,
                                  priority=priority, match=match,
                                  instructions=inst)
        else:
            mod = parser.OFPFlowMod(datapath=datapath, priority=priority,
                                  match=match, instructions=inst)
        datapath.send_msg(mod)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser
        in_port = msg.match['in_port']

        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocols(ethernet.ethernet)[0]

        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            return

        dst = eth.dst
        src = eth.src
        dpid = datapath.id

        self.mac_to_port.setdefault(dpid, {})
        self.mac_to_port[dpid][src] = in_port

        if dst in self.mac_to_port[dpid]:
            out_port = self.mac_to_port[dpid][dst]
        else:
            out_port = ofproto.OFPP_FLOOD

        actions = [parser.OFPActionOutput(out_port)]

        # Install flow to avoid packet_in next time
        if out_port != ofproto.OFPP_FLOOD:
            match = parser.OFPMatch(in_port=in_port, eth_dst=dst, eth_src=src)
            self.add_flow(datapath, 1, match, actions, msg.buffer_id)
            return

        data = None
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data

        out = parser.OFPPacketOut(datapath=datapath, buffer_id=msg.buffer_id,
                                in_port=in_port, actions=actions, data=data)
        datapath.send_msg(out)
```

## 🔧 Network Function Virtualization (NFV)

### NFV Architecture

```
┌─────────────────────────────────────────┐
│        OSS/BSS (Operations)             │
└─────────────┬───────────────────────────┘
┌─────────────▼───────────────────────────┐
│           NFV MANO                      │
│  [Orchestrator] [VNF Manager] [VIM]    │
└─────────────┬───────────────────────────┘
┌─────────────▼───────────────────────────┐
│        NFVI (Infrastructure)            │
│  [Compute] [Storage] [Network]          │
│  [Hypervisor] [Virtual Resources]       │
└─────────────────────────────────────────┘
```

### OpenStack NFV Implementation

**Heat Template for VNF:**
```yaml
# vnf-template.yaml
heat_template_version: 2018-08-31

description: Virtual Network Function Template

parameters:
  vnf_name:
    type: string
    description: Name of the VNF
  flavor:
    type: string
    description: Flavor for VNF instances
  image:
    type: string
    description: Image for VNF instances
  management_network:
    type: string
    description: Management network ID
  data_network:
    type: string
    description: Data network ID

resources:
  vnf_instance:
    type: OS::Nova::Server
    properties:
      name: { get_param: vnf_name }
      flavor: { get_param: flavor }
      image: { get_param: image }
      networks:
        - network: { get_param: management_network }
        - network: { get_param: data_network }
      user_data: |
        #!/bin/bash
        # VNF initialization script
        echo "Initializing VNF..."
        
  vnf_port_mgmt:
    type: OS::Neutron::Port
    properties:
      network: { get_param: management_network }
      security_groups:
        - default

  vnf_port_data:
    type: OS::Neutron::Port
    properties:
      network: { get_param: data_network }

outputs:
  vnf_id:
    description: VNF Instance ID
    value: { get_resource: vnf_instance }
  mgmt_ip:
    description: Management IP
    value: { get_attr: [vnf_port_mgmt, fixed_ips, 0, ip_address] }
```

### OPNFV Integration

**OPNFV Deployment with Fuel:**
```yaml
# fuel-deployment.yaml
cluster:
  name: "nfv-cluster"
  release: "mitaka-9.0"
  
nodes:
  - name: "controller-1"
    role: "controller"
    interfaces:
      - name: "eth0"
        ip: "192.168.1.10"
      - name: "eth1"
        ip: "10.0.0.10"
  
  - name: "compute-1"
    role: "compute"
    interfaces:
      - name: "eth0"
        ip: "192.168.1.20"
      - name: "eth1"
        ip: "10.0.0.20"

network:
  networking_parameters:
    segmentation_type: "vlan"
    net_l23_provider: "ovs"
  
settings:
  editable:
    opendaylight:
      metadata:
        enabled: true
    ovs:
      metadata:
        enabled: true
```

## 🤖 Intent-Based Networking (IBN)

### Network Intent Definition

**Intent Model Example:**
```yaml
# network-intent.yaml
apiVersion: intent.networking.io/v1
kind: NetworkIntent
metadata:
  name: web-app-connectivity
spec:
  description: "Ensure web application connectivity with security"
  
  subjects:
    - selector:
        matchLabels:
          app: web-frontend
      name: "web-tier"
    
    - selector:
        matchLabels:
          app: api-backend
      name: "api-tier"
    
    - selector:
        matchLabels:
          app: database
      name: "db-tier"

  intents:
    - name: "web-to-api-access"
      from: "web-tier"
      to: "api-tier"
      action: "allow"
      protocols: ["http", "https"]
      
    - name: "api-to-db-access"
      from: "api-tier"
      to: "db-tier"
      action: "allow"
      protocols: ["mysql"]
      
    - name: "external-web-access"
      from: "internet"
      to: "web-tier"
      action: "allow"
      protocols: ["https"]
      conditions:
        - type: "rate-limit"
          value: "1000req/min"

  security:
    encryption: "required"
    authentication: "mutual-tls"
    
  performance:
    latency: "< 10ms"
    bandwidth: "> 1Gbps"
    availability: "99.9%"
```

### Intent Translation Engine

**Python Intent Processor:**
```python
#!/usr/bin/env python3
import yaml
import json
from typing import Dict, List

class IntentProcessor:
    def __init__(self, controller_api):
        self.controller = controller_api
        self.intent_cache = {}
    
    def process_intent(self, intent_file: str):
        with open(intent_file, 'r') as f:
            intent = yaml.safe_load(f)
        
        # Validate intent
        if not self.validate_intent(intent):
            raise ValueError("Invalid intent specification")
        
        # Translate to network policies
        policies = self.translate_to_policies(intent)
        
        # Apply to network infrastructure
        for policy in policies:
            self.apply_policy(policy)
        
        # Store intent for monitoring
        self.intent_cache[intent['metadata']['name']] = intent
    
    def validate_intent(self, intent: Dict) -> bool:
        required_fields = ['apiVersion', 'kind', 'metadata', 'spec']
        return all(field in intent for field in required_fields)
    
    def translate_to_policies(self, intent: Dict) -> List[Dict]:
        policies = []
        
        for intent_rule in intent['spec']['intents']:
            # Create network policy
            policy = {
                'type': 'network_policy',
                'name': intent_rule['name'],
                'source': intent_rule['from'],
                'destination': intent_rule['to'],
                'action': intent_rule['action'],
                'protocols': intent_rule['protocols']
            }
            
            # Add security requirements
            if 'security' in intent['spec']:
                policy['security'] = intent['spec']['security']
            
            # Add performance requirements
            if 'performance' in intent['spec']:
                policy['performance'] = intent['spec']['performance']
            
            policies.append(policy)
        
        return policies
    
    def apply_policy(self, policy: Dict):
        # Convert policy to controller-specific format
        if policy['type'] == 'network_policy':
            flow_rules = self.generate_flow_rules(policy)
            for rule in flow_rules:
                self.controller.add_flow_rule(rule)
    
    def generate_flow_rules(self, policy: Dict) -> List[Dict]:
        # Generate OpenFlow rules based on policy
        rules = []
        
        for protocol in policy['protocols']:
            rule = {
                'match': {
                    'eth_type': 0x0800,  # IPv4
                    'ip_proto': self.get_protocol_number(protocol)
                },
                'actions': [
                    {'type': 'OUTPUT', 'port': 'NORMAL'}
                ] if policy['action'] == 'allow' else [
                    {'type': 'DROP'}
                ],
                'priority': 100
            }
            rules.append(rule)
        
        return rules
    
    def get_protocol_number(self, protocol: str) -> int:
        protocol_map = {
            'tcp': 6,
            'udp': 17,
            'icmp': 1,
            'http': 6,  # TCP
            'https': 6,  # TCP
            'mysql': 6   # TCP
        }
        return protocol_map.get(protocol.lower(), 6)

# Usage
processor = IntentProcessor(controller_api)
processor.process_intent('network-intent.yaml')
```

## 🔌 Network APIs and Programmability

### NETCONF/YANG Integration

**NETCONF Client Example:**
```python
#!/usr/bin/env python3
from ncclient import manager
import xml.etree.ElementTree as ET

class NetconfManager:
    def __init__(self, host, username, password, port=830):
        self.host = host
        self.username = username
        self.password = password
        self.port = port
        self.connection = None
    
    def connect(self):
        self.connection = manager.connect(
            host=self.host,
            port=self.port,
            username=self.username,
            password=self.password,
            hostkey_verify=False
        )
    
    def get_config(self, source='running'):
        if not self.connection:
            self.connect()
        
        config = self.connection.get_config(source=source)
        return config.data_xml
    
    def configure_interface(self, interface_name, ip_address, subnet_mask):
        config_xml = f"""
        <config>
            <interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
                <interface>
                    <name>{interface_name}</name>
                    <type xmlns:ianaift="urn:ietf:params:xml:ns:yang:iana-if-type">
                        ianaift:ethernetCsmacd
                    </type>
                    <enabled>true</enabled>
                    <ipv4 xmlns="urn:ietf:params:xml:ns:yang:ietf-ip">
                        <address>
                            <ip>{ip_address}</ip>
                            <netmask>{subnet_mask}</netmask>
                        </address>
                    </ipv4>
                </interface>
            </interfaces>
        </config>
        """
        
        result = self.connection.edit_config(target='candidate', config=config_xml)
        self.connection.commit()
        return result
    
    def close(self):
        if self.connection:
            self.connection.close_session()

# Usage
netconf = NetconfManager('192.168.1.1', 'admin', 'password')
netconf.configure_interface('GigabitEthernet0/1', '192.168.1.10', '255.255.255.0')
netconf.close()
```

### gRPC Network APIs

**gRPC Service Definition:**
```protobuf
// network_service.proto
syntax = "proto3";

package network;

service NetworkService {
    rpc ConfigureInterface(InterfaceConfig) returns (ConfigResponse);
    rpc GetInterfaceStatus(InterfaceRequest) returns (InterfaceStatus);
    rpc CreateVLAN(VLANConfig) returns (ConfigResponse);
    rpc DeleteVLAN(VLANRequest) returns (ConfigResponse);
}

message InterfaceConfig {
    string name = 1;
    string ip_address = 2;
    string subnet_mask = 3;
    bool enabled = 4;
}

message InterfaceRequest {
    string name = 1;
}

message InterfaceStatus {
    string name = 1;
    string status = 2;
    string ip_address = 3;
    int64 rx_bytes = 4;
    int64 tx_bytes = 5;
}

message VLANConfig {
    int32 vlan_id = 1;
    string name = 2;
    repeated string interfaces = 3;
}

message VLANRequest {
    int32 vlan_id = 1;
}

message ConfigResponse {
    bool success = 1;
    string message = 2;
}
```

## ✅ Knowledge Check

- [ ] Understand SDN architecture and OpenFlow
- [ ] Deploy and configure SDN controllers
- [ ] Implement NFV with orchestration
- [ ] Design intent-based networking solutions
- [ ] Develop network automation with APIs
- [ ] Integrate SDN with cloud platforms
- [ ] Monitor and troubleshoot SDN deployments

## 🔗 Next Steps

- [Network Automation](../Network-Automation/) - Advanced automation techniques
- [Cloud Networking](../Cloud-Networking/) - SDN in cloud environments
- [Container Networking](../Container-Networking/) - SDN for containers