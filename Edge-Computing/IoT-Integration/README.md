# IoT Integration at the Edge

## Overview

IoT Integration at the edge involves connecting, managing, and processing data from Internet of Things devices using edge computing infrastructure to enable real-time processing and reduced latency.

## IoT Device Management

### Device Registration and Discovery

```python
# iot_device_manager.py
import json
import sqlite3
from datetime import datetime
from typing import Dict, List, Any, Optional
import paho.mqtt.client as mqtt

class IoTDeviceManager:
    def __init__(self, db_path: str = "iot_devices.db"):
        self.db_path = db_path
        self.devices: Dict[str, Dict] = {}
        self.mqtt_client = None
        self.init_database()
    
    def init_database(self):
        """Initialize SQLite database for device management"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS devices (
                device_id TEXT PRIMARY KEY,
                device_type TEXT NOT NULL,
                manufacturer TEXT,
                model TEXT,
                firmware_version TEXT,
                location TEXT,
                status TEXT DEFAULT 'offline',
                last_seen TIMESTAMP,
                configuration TEXT,
                metadata TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS device_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                device_id TEXT,
                data_type TEXT,
                value REAL,
                unit TEXT,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (device_id) REFERENCES devices (device_id)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def register_device(self, device_info: Dict[str, Any]) -> bool:
        """Register new IoT device"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO devices 
                (device_id, device_type, manufacturer, model, firmware_version, 
                 location, configuration, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                device_info['device_id'],
                device_info['device_type'],
                device_info.get('manufacturer', ''),
                device_info.get('model', ''),
                device_info.get('firmware_version', ''),
                device_info.get('location', ''),
                json.dumps(device_info.get('configuration', {})),
                json.dumps(device_info.get('metadata', {}))
            ))
            
            conn.commit()
            conn.close()
            
            # Store in memory for quick access
            self.devices[device_info['device_id']] = device_info
            
            return True
            
        except Exception as e:
            print(f"Device registration failed: {e}")
            return False
    
    def update_device_status(self, device_id: str, status: str):
        """Update device online/offline status"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE devices 
                SET status = ?, last_seen = CURRENT_TIMESTAMP 
                WHERE device_id = ?
            ''', (status, device_id))
            
            conn.commit()
            conn.close()
            
            if device_id in self.devices:
                self.devices[device_id]['status'] = status
                self.devices[device_id]['last_seen'] = datetime.now()
            
        except Exception as e:
            print(f"Status update failed: {e}")
    
    def get_device_info(self, device_id: str) -> Optional[Dict[str, Any]]:
        """Get device information"""
        if device_id in self.devices:
            return self.devices[device_id]
        
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('SELECT * FROM devices WHERE device_id = ?', (device_id,))
            row = cursor.fetchone()
            conn.close()
            
            if row:
                device_info = {
                    'device_id': row[0],
                    'device_type': row[1],
                    'manufacturer': row[2],
                    'model': row[3],
                    'firmware_version': row[4],
                    'location': row[5],
                    'status': row[6],
                    'last_seen': row[7],
                    'configuration': json.loads(row[8]) if row[8] else {},
                    'metadata': json.loads(row[9]) if row[9] else {}
                }
                self.devices[device_id] = device_info
                return device_info
            
        except Exception as e:
            print(f"Failed to get device info: {e}")
        
        return None
    
    def list_devices(self, device_type: str = None, status: str = None) -> List[Dict[str, Any]]:
        """List devices with optional filtering"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            query = "SELECT * FROM devices WHERE 1=1"
            params = []
            
            if device_type:
                query += " AND device_type = ?"
                params.append(device_type)
            
            if status:
                query += " AND status = ?"
                params.append(status)
            
            cursor.execute(query, params)
            rows = cursor.fetchall()
            conn.close()
            
            devices = []
            for row in rows:
                device_info = {
                    'device_id': row[0],
                    'device_type': row[1],
                    'manufacturer': row[2],
                    'model': row[3],
                    'firmware_version': row[4],
                    'location': row[5],
                    'status': row[6],
                    'last_seen': row[7]
                }
                devices.append(device_info)
            
            return devices
            
        except Exception as e:
            print(f"Failed to list devices: {e}")
            return []
```

### MQTT Communication

```python
# mqtt_iot_gateway.py
import paho.mqtt.client as mqtt
import json
from datetime import datetime
from typing import Dict, Callable, Any

class MQTTIoTGateway:
    def __init__(self, broker_host: str, broker_port: int = 1883):
        self.broker_host = broker_host
        self.broker_port = broker_port
        self.client = mqtt.Client()
        self.message_handlers: Dict[str, Callable] = {}
        self.connected = False
        self.setup_callbacks()
    
    def setup_callbacks(self):
        """Setup MQTT client callbacks"""
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                self.connected = True
                print(f"Connected to MQTT broker at {self.broker_host}:{self.broker_port}")
                
                # Subscribe to device topics
                client.subscribe("devices/+/data")
                client.subscribe("devices/+/status")
                client.subscribe("devices/+/config")
                
            else:
                print(f"Failed to connect to MQTT broker: {rc}")
        
        def on_disconnect(client, userdata, rc):
            self.connected = False
            print("Disconnected from MQTT broker")
        
        def on_message(client, userdata, msg):
            self.handle_message(msg.topic, msg.payload.decode())
        
        self.client.on_connect = on_connect
        self.client.on_disconnect = on_disconnect
        self.client.on_message = on_message
    
    def connect(self):
        """Connect to MQTT broker"""
        try:
            self.client.connect(self.broker_host, self.broker_port, 60)
            self.client.loop_start()
        except Exception as e:
            print(f"MQTT connection failed: {e}")
    
    def disconnect(self):
        """Disconnect from MQTT broker"""
        self.client.loop_stop()
        self.client.disconnect()
    
    def handle_message(self, topic: str, payload: str):
        """Handle incoming MQTT messages"""
        try:
            # Parse topic: devices/{device_id}/{message_type}
            topic_parts = topic.split('/')
            if len(topic_parts) >= 3 and topic_parts[0] == 'devices':
                device_id = topic_parts[1]
                message_type = topic_parts[2]
                
                # Parse payload
                data = json.loads(payload)
                
                # Route message to appropriate handler
                handler_key = f"{message_type}"
                if handler_key in self.message_handlers:
                    self.message_handlers[handler_key](device_id, data)
                else:
                    self.default_message_handler(device_id, message_type, data)
                    
        except Exception as e:
            print(f"Message handling error: {e}")
    
    def register_message_handler(self, message_type: str, handler: Callable):
        """Register custom message handler"""
        self.message_handlers[message_type] = handler
    
    def default_message_handler(self, device_id: str, message_type: str, data: Dict[str, Any]):
        """Default message handler"""
        print(f"Received {message_type} from {device_id}: {data}")
    
    def publish_device_command(self, device_id: str, command: Dict[str, Any]) -> bool:
        """Send command to device"""
        if not self.connected:
            return False
        
        try:
            topic = f"devices/{device_id}/commands"
            payload = json.dumps(command)
            
            result = self.client.publish(topic, payload)
            return result.rc == mqtt.MQTT_ERR_SUCCESS
            
        except Exception as e:
            print(f"Failed to publish command: {e}")
            return False
    
    def publish_device_config(self, device_id: str, config: Dict[str, Any]) -> bool:
        """Send configuration to device"""
        if not self.connected:
            return False
        
        try:
            topic = f"devices/{device_id}/config/update"
            payload = json.dumps(config)
            
            result = self.client.publish(topic, payload)
            return result.rc == mqtt.MQTT_ERR_SUCCESS
            
        except Exception as e:
            print(f"Failed to publish config: {e}")
            return False
```

## Edge Data Processing

### Real-time Data Processing

```python
# edge_data_processor.py
import numpy as np
import pandas as pd
from collections import deque
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional

class EdgeDataProcessor:
    def __init__(self, window_size: int = 100):
        self.window_size = window_size
        self.data_windows: Dict[str, deque] = {}
        self.processing_rules: Dict[str, Dict] = {}
        self.alerts: List[Dict] = []
    
    def add_processing_rule(self, device_type: str, rule_config: Dict[str, Any]):
        """Add data processing rule for device type"""
        self.processing_rules[device_type] = rule_config
    
    def process_sensor_data(self, device_id: str, device_type: str, 
                           sensor_data: Dict[str, float]) -> Dict[str, Any]:
        """Process incoming sensor data in real-time"""
        
        # Initialize data window for device if not exists
        if device_id not in self.data_windows:
            self.data_windows[device_id] = deque(maxlen=self.window_size)
        
        # Add timestamp to data
        timestamped_data = {
            'timestamp': datetime.now(),
            'device_id': device_id,
            'device_type': device_type,
            **sensor_data
        }
        
        # Add to sliding window
        self.data_windows[device_id].append(timestamped_data)
        
        # Process data based on rules
        processing_result = {
            'device_id': device_id,
            'timestamp': timestamped_data['timestamp'],
            'raw_data': sensor_data,
            'processed_data': {},
            'alerts': [],
            'anomalies': []
        }
        
        if device_type in self.processing_rules:
            rules = self.processing_rules[device_type]
            
            # Apply aggregation rules
            if 'aggregations' in rules:
                processing_result['processed_data'].update(
                    self.apply_aggregations(device_id, rules['aggregations'])
                )
            
            # Apply threshold checks
            if 'thresholds' in rules:
                alerts = self.check_thresholds(sensor_data, rules['thresholds'])
                processing_result['alerts'].extend(alerts)
            
            # Apply anomaly detection
            if 'anomaly_detection' in rules:
                anomalies = self.detect_anomalies(device_id, sensor_data, rules['anomaly_detection'])
                processing_result['anomalies'].extend(anomalies)
        
        return processing_result
    
    def apply_aggregations(self, device_id: str, aggregation_rules: Dict[str, List[str]]) -> Dict[str, float]:
        """Apply aggregation functions to windowed data"""
        if device_id not in self.data_windows or len(self.data_windows[device_id]) == 0:
            return {}
        
        # Convert window to DataFrame for easier processing
        window_data = list(self.data_windows[device_id])
        df = pd.DataFrame(window_data)
        
        aggregated_data = {}
        
        for sensor, functions in aggregation_rules.items():
            if sensor in df.columns:
                sensor_values = df[sensor].dropna()
                
                for func in functions:
                    if func == 'mean':
                        aggregated_data[f'{sensor}_mean'] = float(sensor_values.mean())
                    elif func == 'std':
                        aggregated_data[f'{sensor}_std'] = float(sensor_values.std())
                    elif func == 'min':
                        aggregated_data[f'{sensor}_min'] = float(sensor_values.min())
                    elif func == 'max':
                        aggregated_data[f'{sensor}_max'] = float(sensor_values.max())
                    elif func == 'median':
                        aggregated_data[f'{sensor}_median'] = float(sensor_values.median())
        
        return aggregated_data
    
    def check_thresholds(self, sensor_data: Dict[str, float], 
                        threshold_rules: Dict[str, Dict[str, float]]) -> List[Dict[str, Any]]:
        """Check sensor values against thresholds"""
        alerts = []
        
        for sensor, thresholds in threshold_rules.items():
            if sensor in sensor_data:
                value = sensor_data[sensor]
                
                # Check minimum threshold
                if 'min' in thresholds and value < thresholds['min']:
                    alerts.append({
                        'type': 'threshold_violation',
                        'sensor': sensor,
                        'value': value,
                        'threshold': thresholds['min'],
                        'violation_type': 'below_minimum',
                        'severity': thresholds.get('severity', 'medium')
                    })
                
                # Check maximum threshold
                if 'max' in thresholds and value > thresholds['max']:
                    alerts.append({
                        'type': 'threshold_violation',
                        'sensor': sensor,
                        'value': value,
                        'threshold': thresholds['max'],
                        'violation_type': 'above_maximum',
                        'severity': thresholds.get('severity', 'medium')
                    })
        
        return alerts
    
    def detect_anomalies(self, device_id: str, sensor_data: Dict[str, float], 
                        anomaly_config: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Detect anomalies in sensor data"""
        anomalies = []
        
        if device_id not in self.data_windows or len(self.data_windows[device_id]) < 10:
            return anomalies  # Need sufficient data for anomaly detection
        
        # Convert window to DataFrame
        window_data = list(self.data_windows[device_id])
        df = pd.DataFrame(window_data)
        
        method = anomaly_config.get('method', 'statistical')
        
        if method == 'statistical':
            # Statistical anomaly detection using z-score
            threshold = anomaly_config.get('threshold', 3.0)
            
            for sensor, value in sensor_data.items():
                if sensor in df.columns:
                    sensor_values = df[sensor].dropna()
                    
                    if len(sensor_values) > 5:
                        mean_val = sensor_values.mean()
                        std_val = sensor_values.std()
                        
                        if std_val > 0:
                            z_score = abs((value - mean_val) / std_val)
                            
                            if z_score > threshold:
                                anomalies.append({
                                    'type': 'statistical_anomaly',
                                    'sensor': sensor,
                                    'value': value,
                                    'z_score': z_score,
                                    'threshold': threshold,
                                    'mean': mean_val,
                                    'std': std_val
                                })
        
        elif method == 'isolation_forest':
            # Machine learning based anomaly detection
            from sklearn.ensemble import IsolationForest
            
            # Prepare feature matrix
            feature_columns = [col for col in df.columns if col not in ['timestamp', 'device_id', 'device_type']]
            if len(feature_columns) > 0 and len(df) > 10:
                X = df[feature_columns].dropna()
                
                if len(X) > 5:
                    # Fit isolation forest
                    iso_forest = IsolationForest(contamination=0.1, random_state=42)
                    iso_forest.fit(X)
                    
                    # Check current data point
                    current_features = [sensor_data.get(col, 0) for col in feature_columns]
                    anomaly_score = iso_forest.decision_function([current_features])[0]
                    is_anomaly = iso_forest.predict([current_features])[0] == -1
                    
                    if is_anomaly:
                        anomalies.append({
                            'type': 'ml_anomaly',
                            'method': 'isolation_forest',
                            'anomaly_score': anomaly_score,
                            'features': dict(zip(feature_columns, current_features))
                        })
        
        return anomalies
    
    def get_device_statistics(self, device_id: str) -> Dict[str, Any]:
        """Get statistical summary for device data"""
        if device_id not in self.data_windows or len(self.data_windows[device_id]) == 0:
            return {}
        
        # Convert window to DataFrame
        window_data = list(self.data_windows[device_id])
        df = pd.DataFrame(window_data)
        
        # Calculate statistics for numeric columns
        numeric_columns = df.select_dtypes(include=[np.number]).columns
        statistics = {}
        
        for column in numeric_columns:
            if column not in ['timestamp']:
                col_data = df[column].dropna()
                if len(col_data) > 0:
                    statistics[column] = {
                        'count': len(col_data),
                        'mean': float(col_data.mean()),
                        'std': float(col_data.std()),
                        'min': float(col_data.min()),
                        'max': float(col_data.max()),
                        'median': float(col_data.median())
                    }
        
        return statistics
```

## Protocol Integration

### Multiple Protocol Support

```python
# protocol_manager.py
import asyncio
import json
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, Callable
import aiocoap
import aiocoap.resource as resource

class ProtocolHandler(ABC):
    """Abstract base class for protocol handlers"""
    
    @abstractmethod
    async def start(self):
        """Start the protocol handler"""
        pass
    
    @abstractmethod
    async def stop(self):
        """Stop the protocol handler"""
        pass
    
    @abstractmethod
    async def send_message(self, device_id: str, message: Dict[str, Any]) -> bool:
        """Send message to device"""
        pass

class CoAPHandler(ProtocolHandler):
    """CoAP protocol handler for IoT devices"""
    
    def __init__(self, port: int = 5683):
        self.port = port
        self.context = None
        self.message_callback: Optional[Callable] = None
    
    async def start(self):
        """Start CoAP server"""
        root = resource.Site()
        root.add_resource(['sensors'], SensorResource(self.message_callback))
        root.add_resource(['actuators'], ActuatorResource())
        
        self.context = await aiocoap.Context.create_server_context(root, bind=('0.0.0.0', self.port))
        print(f"CoAP server started on port {self.port}")
    
    async def stop(self):
        """Stop CoAP server"""
        if self.context:
            await self.context.shutdown()
    
    async def send_message(self, device_id: str, message: Dict[str, Any]) -> bool:
        """Send CoAP message to device"""
        try:
            # In a real implementation, you'd maintain device endpoints
            device_url = f"coap://device-{device_id}:5683/commands"
            
            context = await aiocoap.Context.create_client_context()
            request = aiocoap.Message(code=aiocoap.POST, payload=json.dumps(message).encode())
            request.set_request_uri(device_url)
            
            response = await context.request(request).response
            await context.shutdown()
            
            return response.code.is_successful()
            
        except Exception as e:
            print(f"CoAP send failed: {e}")
            return False
    
    def set_message_callback(self, callback: Callable):
        """Set callback for incoming messages"""
        self.message_callback = callback

class SensorResource(resource.Resource):
    """CoAP resource for sensor data"""
    
    def __init__(self, message_callback: Optional[Callable] = None):
        super().__init__()
        self.message_callback = message_callback
    
    async def render_post(self, request):
        """Handle POST requests from sensors"""
        try:
            payload = json.loads(request.payload.decode())
            
            if self.message_callback:
                await self.message_callback('coap', payload)
            
            return aiocoap.Message(code=aiocoap.CHANGED, payload=b"Data received")
            
        except Exception as e:
            return aiocoap.Message(code=aiocoap.BAD_REQUEST, payload=str(e).encode())

class ActuatorResource(resource.Resource):
    """CoAP resource for actuator commands"""
    
    async def render_get(self, request):
        """Handle GET requests for actuator status"""
        status = {"status": "ready", "timestamp": "now"}
        return aiocoap.Message(payload=json.dumps(status).encode())

class LoRaWANHandler(ProtocolHandler):
    """LoRaWAN protocol handler"""
    
    def __init__(self, gateway_config: Dict[str, Any]):
        self.gateway_config = gateway_config
        self.devices: Dict[str, Dict] = {}
        self.message_callback: Optional[Callable] = None
    
    async def start(self):
        """Start LoRaWAN gateway simulation"""
        print("LoRaWAN handler started")
        # In real implementation, initialize LoRaWAN gateway
    
    async def stop(self):
        """Stop LoRaWAN handler"""
        print("LoRaWAN handler stopped")
    
    async def send_message(self, device_id: str, message: Dict[str, Any]) -> bool:
        """Send downlink message to LoRaWAN device"""
        try:
            # Simulate LoRaWAN downlink
            if device_id in self.devices:
                print(f"Sending LoRaWAN downlink to {device_id}: {message}")
                return True
            return False
            
        except Exception as e:
            print(f"LoRaWAN send failed: {e}")
            return False
    
    def register_device(self, device_id: str, device_config: Dict[str, Any]):
        """Register LoRaWAN device"""
        self.devices[device_id] = device_config
    
    async def simulate_uplink(self, device_id: str, data: Dict[str, Any]):
        """Simulate LoRaWAN uplink message"""
        if self.message_callback:
            await self.message_callback('lorawan', {
                'device_id': device_id,
                'data': data,
                'rssi': -80,  # Simulated signal strength
                'snr': 7.5    # Simulated signal-to-noise ratio
            })

class ProtocolManager:
    """Manage multiple IoT protocols"""
    
    def __init__(self):
        self.handlers: Dict[str, ProtocolHandler] = {}
        self.message_callbacks: Dict[str, Callable] = {}
    
    def register_handler(self, protocol_name: str, handler: ProtocolHandler):
        """Register protocol handler"""
        self.handlers[protocol_name] = handler
        
        # Set up message callback if handler supports it
        if hasattr(handler, 'set_message_callback'):
            handler.set_message_callback(self.create_message_callback(protocol_name))
    
    def create_message_callback(self, protocol_name: str) -> Callable:
        """Create message callback for protocol"""
        async def callback(protocol: str, message: Dict[str, Any]):
            if protocol_name in self.message_callbacks:
                await self.message_callbacks[protocol_name](message)
            else:
                print(f"Received {protocol} message: {message}")
        
        return callback
    
    def set_message_callback(self, protocol_name: str, callback: Callable):
        """Set message callback for specific protocol"""
        self.message_callbacks[protocol_name] = callback
    
    async def start_all(self):
        """Start all registered protocol handlers"""
        for name, handler in self.handlers.items():
            try:
                await handler.start()
                print(f"Started {name} protocol handler")
            except Exception as e:
                print(f"Failed to start {name} handler: {e}")
    
    async def stop_all(self):
        """Stop all protocol handlers"""
        for name, handler in self.handlers.items():
            try:
                await handler.stop()
                print(f"Stopped {name} protocol handler")
            except Exception as e:
                print(f"Failed to stop {name} handler: {e}")
    
    async def send_message(self, protocol_name: str, device_id: str, 
                          message: Dict[str, Any]) -> bool:
        """Send message via specific protocol"""
        if protocol_name in self.handlers:
            return await self.handlers[protocol_name].send_message(device_id, message)
        return False
    
    def get_supported_protocols(self) -> List[str]:
        """Get list of supported protocols"""
        return list(self.handlers.keys())
```

## Best Practices

### IoT Edge Integration Best Practices

1. **Device Management**
   - Automated device discovery and registration
   - Secure device authentication
   - Firmware update management
   - Device health monitoring

2. **Data Processing**
   - Real-time stream processing
   - Edge analytics and filtering
   - Data aggregation and compression
   - Intelligent data routing

3. **Protocol Support**
   - Multi-protocol gateway support
   - Protocol translation and bridging
   - Standardized data formats
   - Backward compatibility

4. **Security**
   - End-to-end encryption
   - Device identity management
   - Secure communication channels
   - Regular security updates

5. **Scalability**
   - Horizontal scaling of edge gateways
   - Load balancing across protocols
   - Efficient resource utilization
   - Dynamic device provisioning

## Conclusion

IoT Integration at the edge enables efficient management and processing of IoT device data with reduced latency and improved reliability. Success requires comprehensive device management, real-time data processing capabilities, multi-protocol support, and robust security measures.