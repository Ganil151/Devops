# MongoDB Administration

Complete guide to MongoDB installation, configuration, and management for production environments.

## Installation

### RHEL/CentOS/Amazon Linux
```bash
# Add MongoDB repository
cat > /etc/yum.repos.d/mongodb-org-7.0.repo << EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF

# Install MongoDB
sudo yum install -y mongodb-org

# Start and enable service
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Ubuntu/Debian
```bash
# Import public key
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -

# Add repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Start and enable service
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Docker Installation
```bash
# Run MongoDB container
docker run -d \
  --name mongo-petclinic \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=admin \
  -e MONGO_INITDB_DATABASE=petclinic \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  mongo:7.0

# Connect to container
docker exec -it mongo-petclinic mongosh -u admin -p admin
```

## Configuration

### Main Configuration File
```yaml
# /etc/mongod.conf
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true

processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid

net:
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: enabled

replication:
  replSetName: rs0

sharding:
  clusterRole: shardsvr
```

### Security Configuration
```javascript
// Enable authentication
use admin
db.createUser({
  user: "admin",
  pwd: "admin_password",
  roles: ["root"]
})

// Create application user
use petclinic
db.createUser({
  user: "petclinic",
  pwd: "petclinic_password",
  roles: ["readWrite"]
})

// Create read-only user
db.createUser({
  user: "readonly",
  pwd: "readonly_password",
  roles: ["read"]
})
```

## Database Operations

### Connection
```bash
# Connect to MongoDB
mongosh

# Connect with authentication
mongosh -u admin -p admin_password --authenticationDatabase admin

# Connect to specific database
mongosh petclinic -u petclinic -p petclinic_password

# Connect to remote host
mongosh "mongodb://petclinic:password@hostname:27017/petclinic"

# Connect with connection string
mongosh "mongodb+srv://username:password@cluster.mongodb.net/database"
```

### Database Management
```javascript
// List databases
show dbs

// Switch to database
use petclinic

// Show current database
db

// Create database (implicitly created when first document is inserted)
use new_database

// Drop database
db.dropDatabase()

// Database statistics
db.stats()

// Database size
db.stats().dataSize
```

### Collection Management
```javascript
// List collections
show collections

// Create collection
db.createCollection("owners")

// Create collection with options
db.createCollection("owners", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["firstName", "lastName"],
      properties: {
        firstName: {
          bsonType: "string",
          description: "must be a string and is required"
        },
        lastName: {
          bsonType: "string",
          description: "must be a string and is required"
        }
      }
    }
  }
})

// Drop collection
db.owners.drop()

// Collection statistics
db.owners.stats()

// Rename collection
db.owners.renameCollection("pet_owners")
```

## CRUD Operations

### Insert Documents
```javascript
// Insert single document
db.owners.insertOne({
  firstName: "John",
  lastName: "Doe",
  address: "123 Main St",
  city: "Madison",
  telephone: "608-555-1234",
  createdAt: new Date()
})

// Insert multiple documents
db.owners.insertMany([
  {
    firstName: "Jane",
    lastName: "Smith",
    city: "Monona",
    telephone: "608-555-2345"
  },
  {
    firstName: "Bob",
    lastName: "Johnson",
    city: "Sun Prairie",
    telephone: "608-555-3456"
  }
])

// Insert with specific _id
db.owners.insertOne({
  _id: ObjectId("507f1f77bcf86cd799439011"),
  firstName: "Alice",
  lastName: "Williams"
})
```

### Query Documents
```javascript
// Find all documents
db.owners.find()

// Find with pretty formatting
db.owners.find().pretty()

// Find specific document
db.owners.findOne({firstName: "John"})

// Find with conditions
db.owners.find({city: "Madison"})

// Find with multiple conditions (AND)
db.owners.find({
  city: "Madison",
  lastName: "Doe"
})

// Find with OR conditions
db.owners.find({
  $or: [
    {city: "Madison"},
    {city: "Monona"}
  ]
})

// Find with comparison operators
db.owners.find({
  createdAt: {$gte: new Date("2024-01-01")}
})

// Find with regex
db.owners.find({
  lastName: /^D/i
})

// Find with projection (select specific fields)
db.owners.find({}, {firstName: 1, lastName: 1, _id: 0})

// Find with limit and skip
db.owners.find().limit(10).skip(20)

// Find with sorting
db.owners.find().sort({lastName: 1, firstName: 1})

// Count documents
db.owners.countDocuments()
db.owners.countDocuments({city: "Madison"})
```

### Update Documents
```javascript
// Update single document
db.owners.updateOne(
  {firstName: "John"},
  {$set: {telephone: "608-555-9999"}}
)

// Update multiple documents
db.owners.updateMany(
  {city: "Madison"},
  {$set: {state: "WI"}}
)

// Replace entire document
db.owners.replaceOne(
  {firstName: "John"},
  {
    firstName: "Jonathan",
    lastName: "Doe",
    city: "Madison",
    telephone: "608-555-8888"
  }
)

// Update with upsert (insert if not exists)
db.owners.updateOne(
  {firstName: "Mike"},
  {$set: {lastName: "Brown", city: "Madison"}},
  {upsert: true}
)

// Update with array operations
db.owners.updateOne(
  {firstName: "John"},
  {$push: {pets: "Max"}}
)

// Update with increment
db.owners.updateOne(
  {firstName: "John"},
  {$inc: {petCount: 1}}
)
```

### Delete Documents
```javascript
// Delete single document
db.owners.deleteOne({firstName: "John"})

// Delete multiple documents
db.owners.deleteMany({city: "Madison"})

// Delete all documents
db.owners.deleteMany({})
```

## Indexing

### Index Operations
```javascript
// Create index
db.owners.createIndex({lastName: 1})

// Create compound index
db.owners.createIndex({city: 1, lastName: 1})

// Create text index
db.owners.createIndex({
  firstName: "text",
  lastName: "text",
  address: "text"
})

// Create unique index
db.owners.createIndex({telephone: 1}, {unique: true})

// Create partial index
db.owners.createIndex(
  {telephone: 1},
  {partialFilterExpression: {telephone: {$exists: true}}}
)

// Create TTL index (expires documents)
db.sessions.createIndex(
  {createdAt: 1},
  {expireAfterSeconds: 3600}
)

// List indexes
db.owners.getIndexes()

// Drop index
db.owners.dropIndex({lastName: 1})

// Drop all indexes except _id
db.owners.dropIndexes()

// Rebuild indexes
db.owners.reIndex()
```

### Index Performance
```javascript
// Explain query execution
db.owners.find({lastName: "Doe"}).explain("executionStats")

// Check index usage
db.owners.aggregate([
  {$indexStats: {}}
])

// Find unused indexes
db.runCommand({
  aggregate: "owners",
  pipeline: [{$indexStats: {}}],
  cursor: {}
})
```

## Aggregation Framework

### Basic Aggregation
```javascript
// Group by city and count
db.owners.aggregate([
  {$group: {
    _id: "$city",
    count: {$sum: 1}
  }}
])

// Match and group
db.owners.aggregate([
  {$match: {city: "Madison"}},
  {$group: {
    _id: "$lastName",
    count: {$sum: 1}
  }}
])

// Project specific fields
db.owners.aggregate([
  {$project: {
    fullName: {$concat: ["$firstName", " ", "$lastName"]},
    city: 1
  }}
])

// Sort results
db.owners.aggregate([
  {$group: {
    _id: "$city",
    count: {$sum: 1}
  }},
  {$sort: {count: -1}}
])

// Limit results
db.owners.aggregate([
  {$group: {
    _id: "$city",
    count: {$sum: 1}
  }},
  {$sort: {count: -1}},
  {$limit: 5}
])
```

### Advanced Aggregation
```javascript
// Lookup (join) collections
db.owners.aggregate([
  {$lookup: {
    from: "pets",
    localField: "_id",
    foreignField: "ownerId",
    as: "pets"
  }}
])

// Unwind arrays
db.owners.aggregate([
  {$lookup: {
    from: "pets",
    localField: "_id",
    foreignField: "ownerId",
    as: "pets"
  }},
  {$unwind: "$pets"}
])

// Add computed fields
db.owners.aggregate([
  {$addFields: {
    fullName: {$concat: ["$firstName", " ", "$lastName"]},
    hasPhone: {$ne: ["$telephone", null]}
  }}
])

// Conditional operations
db.owners.aggregate([
  {$project: {
    firstName: 1,
    lastName: 1,
    location: {
      $cond: {
        if: {$eq: ["$city", "Madison"]},
        then: "Local",
        else: "Remote"
      }
    }
  }}
])
```

## Backup and Restore

### Backup Operations
```bash
# Backup entire MongoDB instance
mongodump --host localhost --port 27017

# Backup specific database
mongodump --host localhost --port 27017 --db petclinic

# Backup specific collection
mongodump --host localhost --port 27017 --db petclinic --collection owners

# Backup with authentication
mongodump --host localhost --port 27017 --username admin --password admin_password --authenticationDatabase admin

# Backup to specific directory
mongodump --host localhost --port 27017 --db petclinic --out /backup/mongodb/

# Backup with compression
mongodump --host localhost --port 27017 --db petclinic --gzip

# Backup with query filter
mongodump --host localhost --port 27017 --db petclinic --collection owners --query '{"city": "Madison"}'

# Create archive
mongodump --host localhost --port 27017 --db petclinic --archive=petclinic.archive

# Backup to remote location
mongodump --host localhost --port 27017 --db petclinic --archive | ssh user@backup-server "cat > /backup/petclinic.archive"
```

### Restore Operations
```bash
# Restore entire backup
mongorestore --host localhost --port 27017 /backup/mongodb/

# Restore specific database
mongorestore --host localhost --port 27017 --db petclinic /backup/mongodb/petclinic/

# Restore specific collection
mongorestore --host localhost --port 27017 --db petclinic --collection owners /backup/mongodb/petclinic/owners.bson

# Restore with authentication
mongorestore --host localhost --port 27017 --username admin --password admin_password --authenticationDatabase admin /backup/mongodb/

# Restore and drop existing collections
mongorestore --host localhost --port 27017 --db petclinic --drop /backup/mongodb/petclinic/

# Restore from archive
mongorestore --host localhost --port 27017 --archive=petclinic.archive

# Restore from compressed backup
mongorestore --host localhost --port 27017 --gzip /backup/mongodb/

# Restore to different database
mongorestore --host localhost --port 27017 --db petclinic_backup /backup/mongodb/petclinic/
```

## Replication

### Replica Set Setup
```javascript
// Initialize replica set
rs.initiate({
  _id: "rs0",
  members: [
    {_id: 0, host: "mongo1:27017"},
    {_id: 1, host: "mongo2:27017"},
    {_id: 2, host: "mongo3:27017"}
  ]
})

// Add member to replica set
rs.add("mongo4:27017")

// Remove member from replica set
rs.remove("mongo4:27017")

// Check replica set status
rs.status()

// Check replica set configuration
rs.conf()

// Step down primary (force election)
rs.stepDown()

// Check if current node is primary
db.isMaster()
```

### Replica Set Monitoring
```javascript
// Check replication lag
rs.printReplicationInfo()

// Check slave status
rs.printSlaveReplicationInfo()

// Get replica set status
db.runCommand({replSetGetStatus: 1})

// Check oplog size
db.oplog.rs.stats()

// Find slow operations in oplog
db.oplog.rs.find().sort({ts: -1}).limit(10)
```

## Performance Monitoring

### Database Statistics
```javascript
// Server status
db.runCommand({serverStatus: 1})

// Database statistics
db.stats()

// Collection statistics
db.owners.stats()

// Index statistics
db.owners.aggregate([{$indexStats: {}}])

// Current operations
db.currentOp()

// Kill operation
db.killOp(opid)

// Profile slow operations
db.setProfilingLevel(2, {slowms: 100})

// View profiler data
db.system.profile.find().sort({ts: -1}).limit(5)
```

### Performance Queries
```javascript
// Find slow queries
db.system.profile.find({
  millis: {$gt: 1000}
}).sort({ts: -1})

// Connection statistics
db.runCommand({connPoolStats: 1})

// Lock statistics
db.runCommand({serverStatus: 1}).locks

// Memory usage
db.runCommand({serverStatus: 1}).mem

// Network statistics
db.runCommand({serverStatus: 1}).network
```

## Security

### Authentication and Authorization
```javascript
// Create admin user
use admin
db.createUser({
  user: "admin",
  pwd: "secure_password",
  roles: ["root"]
})

// Create database user
use petclinic
db.createUser({
  user: "petclinic_app",
  pwd: "app_password",
  roles: [
    {role: "readWrite", db: "petclinic"}
  ]
})

// Create custom role
use admin
db.createRole({
  role: "petclinicAdmin",
  privileges: [
    {
      resource: {db: "petclinic", collection: ""},
      actions: ["find", "insert", "update", "remove", "createIndex"]
    }
  ],
  roles: []
})

// Grant role to user
db.grantRolesToUser("petclinic_app", ["petclinicAdmin"])

// List users
db.getUsers()

// Drop user
db.dropUser("username")
```

### SSL/TLS Configuration
```yaml
# mongod.conf
net:
  ssl:
    mode: requireSSL
    PEMKeyFile: /etc/ssl/mongodb.pem
    CAFile: /etc/ssl/ca.pem
```

## Troubleshooting

### Common Issues
```bash
# Check MongoDB status
sudo systemctl status mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log

# Check port availability
netstat -tulpn | grep 27017

# Test connection
mongosh --eval "db.runCommand({ping: 1})"

# Check disk space
df -h /var/lib/mongo

# Check memory usage
free -h
```

### Performance Issues
```javascript
// Check current operations
db.currentOp({
  "active": true,
  "secs_running": {$gte: 5}
})

// Kill long-running operations
db.currentOp().inprog.forEach(
  function(op) {
    if (op.secs_running > 300) {
      db.killOp(op.opid);
    }
  }
)

// Check index usage
db.owners.find({lastName: "Doe"}).explain("executionStats")

// Analyze query performance
db.owners.explain("executionStats").find({city: "Madison"})
```

This comprehensive MongoDB guide covers all essential administration tasks for production environments.