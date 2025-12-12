# Microservices with Docker

Complete guide to containerizing and orchestrating microservices architecture with Docker.

## Microservices Architecture Overview

### Key Principles

- **Single Responsibility**: Each service handles one business capability
- **Decentralized**: Independent deployment and scaling
- **Technology Agnostic**: Different services can use different technologies
- **Fault Isolation**: Failure in one service doesn't affect others
- **Data Independence**: Each service manages its own data

### Docker Benefits for Microservices

- **Consistency**: Same environment across development, testing, and production
- **Isolation**: Services run in isolated containers
- **Scalability**: Independent scaling of services
- **Portability**: Deploy anywhere Docker runs
- **Resource Efficiency**: Lightweight compared to VMs

## Basic Microservices Setup

### Service Structure

```
microservices-app/
├── api-gateway/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── user-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
├── order-service/
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/
├── notification-service/
│   ├── Dockerfile
│   ├── go.mod
│   └── main.go
└── docker-compose.yml
```

### API Gateway Service

```dockerfile
# api-gateway/Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

USER 1000:1000

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
```

```javascript
// api-gateway/src/server.js
const express = require('express');
const httpProxy = require('http-proxy-middleware');

const app = express();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Proxy to user service
app.use('/api/users', httpProxy({
  target: 'http://user-service:5000',
  changeOrigin: true,
  pathRewrite: { '^/api/users': '' }
}));

// Proxy to order service
app.use('/api/orders', httpProxy({
  target: 'http://order-service:8080',
  changeOrigin: true,
  pathRewrite: { '^/api/orders': '' }
}));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});
```

### User Service (Python/Flask)

```dockerfile
# user-service/Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN adduser --disabled-password --gecos '' appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
```

```python
# user-service/app.py
from flask import Flask, jsonify, request
import os
import psycopg2

app = Flask(__name__)

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'user-db'),
        database=os.getenv('DB_NAME', 'users'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM users')
    users = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(users)

@app.route('/users', methods=['POST'])
def create_user():
    data = request.json
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        'INSERT INTO users (name, email) VALUES (%s, %s)',
        (data['name'], data['email'])
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({'message': 'User created'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Order Service (Java/Spring Boot)

```dockerfile
# order-service/Dockerfile
FROM openjdk:11-jre-slim

WORKDIR /app

COPY target/order-service.jar app.jar

RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

```java
// order-service/src/main/java/OrderController.java
@RestController
@RequestMapping("/orders")
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "healthy");
        return ResponseEntity.ok(status);
    }
    
    @GetMapping
    public List<Order> getAllOrders() {
        return orderService.getAllOrders();
    }
    
    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody Order order) {
        Order createdOrder = orderService.createOrder(order);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdOrder);
    }
}
```

## Docker Compose Configuration

### Complete Microservices Stack

```yaml
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  api-gateway:
    build: ./api-gateway
    container_name: api-gateway
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - user-service
      - order-service
      - notification-service
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # User Service
  user-service:
    build: ./user-service
    container_name: user-service
    restart: unless-stopped
    environment:
      - DB_HOST=user-db
      - DB_NAME=users
      - DB_USER=postgres
      - DB_PASSWORD=${USER_DB_PASSWORD}
    depends_on:
      - user-db
    networks:
      - microservices-network
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  # Order Service
  order-service:
    build: ./order-service
    container_name: order-service
    restart: unless-stopped
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://order-db:3306/orders
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=${ORDER_DB_PASSWORD}
    depends_on:
      - order-db
    networks:
      - microservices-network
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1'

  # Notification Service
  notification-service:
    build: ./notification-service
    container_name: notification-service
    restart: unless-stopped
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - redis
    networks:
      - microservices-network

  # Databases
  user-db:
    image: postgres:13
    container_name: user-db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=users
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${USER_DB_PASSWORD}
    volumes:
      - user-db-data:/var/lib/postgresql/data
      - ./user-service/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - microservices-network

  order-db:
    image: mysql:8.0
    container_name: order-db
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=${ORDER_DB_PASSWORD}
      - MYSQL_DATABASE=orders
    volumes:
      - order-db-data:/var/lib/mysql
      - ./order-service/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - microservices-network

  # Cache
  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    volumes:
      - redis-data:/data
    networks:
      - microservices-network

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    container_name: rabbitmq
    restart: unless-stopped
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASSWORD}
    ports:
      - "15672:15672"  # Management UI
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq
    networks:
      - microservices-network

volumes:
  user-db-data:
  order-db-data:
  redis-data:
  rabbitmq-data:

networks:
  microservices-network:
    driver: bridge
```

## Service Discovery and Communication

### Service Registry with Consul

```yaml
# Add to docker-compose.yml
  consul:
    image: consul:1.15
    container_name: consul
    restart: unless-stopped
    ports:
      - "8500:8500"
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
    networks:
      - microservices-network
```

### Service Registration

```javascript
// Service registration in Node.js
const consul = require('consul')();

const registerService = () => {
  const serviceDefinition = {
    name: 'user-service',
    address: 'user-service',
    port: 5000,
    check: {
      http: 'http://user-service:5000/health',
      interval: '30s'
    }
  };
  
  consul.agent.service.register(serviceDefinition, (err) => {
    if (err) console.error('Service registration failed:', err);
    else console.log('Service registered successfully');
  });
};
```

## Load Balancing and Scaling

### Nginx Load Balancer

```nginx
# nginx.conf
upstream user-service {
    server user-service-1:5000;
    server user-service-2:5000;
    server user-service-3:5000;
}

upstream order-service {
    server order-service-1:8080;
    server order-service-2:8080;
}

server {
    listen 80;
    
    location /api/users {
        proxy_pass http://user-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api/orders {
        proxy_pass http://order-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Docker Swarm Scaling

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml microservices

# Scale services
docker service scale microservices_user-service=3
docker service scale microservices_order-service=2

# Update service
docker service update --image user-service:v2 microservices_user-service
```

## Monitoring and Logging

### Centralized Logging with ELK Stack

```yaml
# Add to docker-compose.yml
  elasticsearch:
    image: elasticsearch:7.17.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - microservices-network

  logstash:
    image: logstash:7.17.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
    depends_on:
      - elasticsearch
    networks:
      - microservices-network

  kibana:
    image: kibana:7.17.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - microservices-network
```

### Prometheus Monitoring

```yaml
# Add to docker-compose.yml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    networks:
      - microservices-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - microservices-network
```

## Security Best Practices

### Service-to-Service Authentication

```yaml
# JWT-based authentication
services:
  auth-service:
    build: ./auth-service
    container_name: auth-service
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - JWT_EXPIRY=3600
    networks:
      - microservices-network
```

### Network Security

```yaml
# Separate networks for different tiers
networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge
    internal: true  # No external access
  database-network:
    driver: bridge
    internal: true  # No external access

services:
  api-gateway:
    networks:
      - frontend-network
      - backend-network
  
  user-service:
    networks:
      - backend-network
      - database-network
  
  user-db:
    networks:
      - database-network
```

### Secrets Management

```yaml
# Using Docker secrets
secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

services:
  user-service:
    secrets:
      - db_password
      - jwt_secret
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - JWT_SECRET_FILE=/run/secrets/jwt_secret
```

## Testing Microservices

### Integration Testing

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  test-runner:
    build: ./tests
    container_name: test-runner
    environment:
      - API_GATEWAY_URL=http://api-gateway:3000
      - USER_SERVICE_URL=http://user-service:5000
      - ORDER_SERVICE_URL=http://order-service:8080
    depends_on:
      - api-gateway
      - user-service
      - order-service
    networks:
      - microservices-network
    command: npm test

networks:
  microservices-network:
    external: true
```

### Contract Testing

```javascript
// Pact contract testing example
const { Pact } = require('@pact-foundation/pact');

const provider = new Pact({
  consumer: 'api-gateway',
  provider: 'user-service',
  port: 1234,
  log: path.resolve(process.cwd(), 'logs', 'pact.log'),
  dir: path.resolve(process.cwd(), 'pacts'),
  logLevel: 'INFO'
});

describe('User Service Contract', () => {
  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());

  it('should get users', async () => {
    await provider.addInteraction({
      state: 'users exist',
      uponReceiving: 'a request for users',
      withRequest: {
        method: 'GET',
        path: '/users'
      },
      willRespondWith: {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: [{ id: 1, name: 'John Doe' }]
      }
    });

    const response = await axios.get('http://localhost:1234/users');
    expect(response.status).toBe(200);
  });
});
```

## Deployment Strategies

### Blue-Green Deployment

```bash
#!/bin/bash
# blue-green-deploy.sh

# Deploy green environment
docker-compose -f docker-compose.green.yml up -d

# Health check
./health-check.sh green

# Switch traffic
docker-compose -f docker-compose.blue.yml down
docker-compose -f docker-compose.green.yml up -d

# Cleanup old environment
docker-compose -f docker-compose.blue.yml down --volumes
```

### Canary Deployment

```yaml
# Canary deployment with Traefik
version: '3.8'

services:
  traefik:
    image: traefik:v2.9
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command:
      - --api.insecure=true
      - --providers.docker=true

  user-service-v1:
    image: user-service:v1
    labels:
      - "traefik.http.routers.user-v1.rule=Host(`api.example.com`) && Path(`/users`)"
      - "traefik.http.services.user-v1.loadbalancer.server.port=5000"
      - "traefik.http.routers.user-v1.service=user-v1"
    deploy:
      replicas: 9

  user-service-v2:
    image: user-service:v2
    labels:
      - "traefik.http.routers.user-v2.rule=Host(`api.example.com`) && Path(`/users`)"
      - "traefik.http.services.user-v2.loadbalancer.server.port=5000"
      - "traefik.http.routers.user-v2.service=user-v2"
    deploy:
      replicas: 1  # 10% traffic
```

## Production Considerations

### Resource Management

```yaml
# Production resource limits
services:
  user-service:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```

### Health Checks and Circuit Breakers

```javascript
// Circuit breaker implementation
const CircuitBreaker = require('opossum');

const options = {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000
};

const breaker = new CircuitBreaker(callUserService, options);

breaker.fallback(() => 'Service temporarily unavailable');

breaker.on('open', () => console.log('Circuit breaker is open'));
breaker.on('halfOpen', () => console.log('Circuit breaker is half-open'));
```

### Backup and Disaster Recovery

```bash
#!/bin/bash
# backup-microservices.sh

# Backup databases
docker exec user-db pg_dump -U postgres users > backups/user-db-$(date +%Y%m%d).sql
docker exec order-db mysqldump -u root -p orders > backups/order-db-$(date +%Y%m%d).sql

# Backup configurations
tar -czf backups/configs-$(date +%Y%m%d).tar.gz ./configs/

# Backup Docker images
docker save user-service:latest | gzip > backups/user-service-$(date +%Y%m%d).tar.gz
docker save order-service:latest | gzip > backups/order-service-$(date +%Y%m%d).tar.gz
```