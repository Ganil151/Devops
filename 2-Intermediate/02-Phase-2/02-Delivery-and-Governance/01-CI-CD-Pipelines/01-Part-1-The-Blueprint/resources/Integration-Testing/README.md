# Integration Testing

Complete guide to integration testing strategies and implementation.

## Integration Testing Types

### Component Integration
```bash
# Test interaction between components
# Database integration
# API integration
# Service communication

# Example: Database Integration Test
def test_user_creation():
    user = create_user("John", "john@example.com")
    saved_user = db.get_user(user.id)
    assert saved_user.name == "John"
```

### API Integration Testing
```bash
# REST API Testing
curl -X POST http://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# Postman/Newman
newman run collection.json -e environment.json

# REST Assured (Java)
given()
  .contentType(ContentType.JSON)
  .body(user)
.when()
  .post("/api/users")
.then()
  .statusCode(201)
  .body("name", equalTo("John"));
```

### Database Integration
```python
# Python Database Testing
import pytest
from sqlalchemy import create_engine
from myapp.models import User

@pytest.fixture
def test_db():
    engine = create_engine('sqlite:///:memory:')
    Base.metadata.create_all(engine)
    return engine

def test_user_crud_operations(test_db):
    # Create
    user = User(name="John", email="john@example.com")
    session.add(user)
    session.commit()
    
    # Read
    retrieved_user = session.query(User).filter_by(name="John").first()
    assert retrieved_user.email == "john@example.com"
    
    # Update
    retrieved_user.email = "john.doe@example.com"
    session.commit()
    
    # Delete
    session.delete(retrieved_user)
    session.commit()
```

### Microservices Integration
```yaml
# Docker Compose for Integration Testing
version: '3'
services:
  app:
    build: .
    depends_on:
      - database
      - redis
    environment:
      - DATABASE_URL=postgresql://user:pass@database:5432/testdb
      - REDIS_URL=redis://redis:6379
  
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
  
  redis:
    image: redis:6-alpine
```

## Contract Testing

### Pact Testing
```javascript
// Consumer Test (Pact)
const { Pact } = require('@pact-foundation/pact');

describe('User API', () => {
  const provider = new Pact({
    consumer: 'UserService',
    provider: 'UserAPI'
  });

  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());

  test('should get user by id', async () => {
    await provider
      .given('user with id 1 exists')
      .uponReceiving('a request for user 1')
      .withRequest({
        method: 'GET',
        path: '/users/1'
      })
      .willRespondWith({
        status: 200,
        body: { id: 1, name: 'John' }
      });

    const response = await userService.getUser(1);
    expect(response.name).toBe('John');
  });
});
```

### Schema Validation
```javascript
// JSON Schema Validation
const Ajv = require('ajv');
const ajv = new Ajv();

const userSchema = {
  type: 'object',
  properties: {
    id: { type: 'integer' },
    name: { type: 'string' },
    email: { type: 'string', format: 'email' }
  },
  required: ['id', 'name', 'email']
};

test('API response should match schema', async () => {
  const response = await api.get('/users/1');
  const validate = ajv.compile(userSchema);
  const valid = validate(response.data);
  expect(valid).toBe(true);
});
```

## Test Environment Management

### Environment Setup
```bash
# Test Environment with Docker
# Dockerfile.test
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
CMD ["npm", "run", "test:integration"]

# Test Environment Variables
export NODE_ENV=test
export DATABASE_URL=postgresql://test:test@localhost:5433/testdb
export REDIS_URL=redis://localhost:6380
```

### Data Management
```python
# Test Data Fixtures
@pytest.fixture
def sample_users():
    return [
        {"name": "John", "email": "john@example.com"},
        {"name": "Jane", "email": "jane@example.com"}
    ]

@pytest.fixture(autouse=True)
def setup_test_data(test_db, sample_users):
    # Setup
    for user_data in sample_users:
        user = User(**user_data)
        test_db.session.add(user)
    test_db.session.commit()
    
    yield
    
    # Cleanup
    test_db.session.query(User).delete()
    test_db.session.commit()
```