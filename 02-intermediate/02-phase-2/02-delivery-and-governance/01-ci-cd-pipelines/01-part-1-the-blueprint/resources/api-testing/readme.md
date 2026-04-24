# API Testing

Complete guide to API testing strategies, tools, and automation.

## API Testing Fundamentals

### REST API Testing
```bash
# HTTP Methods Testing
# GET - Retrieve data
curl -X GET http://api.example.com/users/1

# POST - Create new resource
curl -X POST http://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# PUT - Update entire resource
curl -X PUT http://api.example.com/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john.doe@example.com"}'

# PATCH - Partial update
curl -X PATCH http://api.example.com/users/1 \
  -H "Content-Type: application/json" \
  -d '{"email":"newemail@example.com"}'

# DELETE - Remove resource
curl -X DELETE http://api.example.com/users/1
```

### Status Code Validation
```bash
# Success Codes
200 OK - Successful GET, PUT, PATCH
201 Created - Successful POST
204 No Content - Successful DELETE

# Client Error Codes
400 Bad Request - Invalid request
401 Unauthorized - Authentication required
403 Forbidden - Access denied
404 Not Found - Resource not found
422 Unprocessable Entity - Validation errors

# Server Error Codes
500 Internal Server Error - Server error
502 Bad Gateway - Gateway error
503 Service Unavailable - Service down
```

## API Testing Tools

### Postman/Newman
```javascript
// Postman Test Script
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response time is less than 200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});

pm.test("Response has required fields", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('id');
    pm.expect(jsonData).to.have.property('name');
    pm.expect(jsonData).to.have.property('email');
});

// Environment Variables
pm.environment.set("user_id", pm.response.json().id);

// Newman CLI
newman run collection.json -e environment.json -r html,json
```

### REST Assured (Java)
```java
import io.restassured.RestAssured;
import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

public class UserAPITest {
    
    @BeforeClass
    public static void setup() {
        RestAssured.baseURI = "http://api.example.com";
    }
    
    @Test
    public void testGetUser() {
        given()
            .pathParam("id", 1)
        .when()
            .get("/users/{id}")
        .then()
            .statusCode(200)
            .body("name", notNullValue())
            .body("email", containsString("@"))
            .time(lessThan(2000L));
    }
    
    @Test
    public void testCreateUser() {
        User user = new User("John", "john@example.com");
        
        given()
            .contentType(ContentType.JSON)
            .body(user)
        .when()
            .post("/users")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("name", equalTo("John"));
    }
}
```

### Supertest (Node.js)
```javascript
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  test('GET /users should return all users', async () => {
    const response = await request(app)
      .get('/users')
      .expect(200)
      .expect('Content-Type', /json/);
    
    expect(Array.isArray(response.body)).toBe(true);
  });
  
  test('POST /users should create new user', async () => {
    const newUser = {
      name: 'John Doe',
      email: 'john@example.com'
    };
    
    const response = await request(app)
      .post('/users')
      .send(newUser)
      .expect(201)
      .expect('Content-Type', /json/);
    
    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe(newUser.name);
  });
  
  test('GET /users/:id should return specific user', async () => {
    const response = await request(app)
      .get('/users/1')
      .expect(200);
    
    expect(response.body).toHaveProperty('id', 1);
  });
});
```

### pytest with requests (Python)
```python
import pytest
import requests
import json

class TestUserAPI:
    base_url = "http://api.example.com"
    
    def test_get_users(self):
        response = requests.get(f"{self.base_url}/users")
        
        assert response.status_code == 200
        assert response.headers['content-type'] == 'application/json'
        assert isinstance(response.json(), list)
    
    def test_create_user(self):
        user_data = {
            "name": "John Doe",
            "email": "john@example.com"
        }
        
        response = requests.post(
            f"{self.base_url}/users",
            json=user_data,
            headers={'Content-Type': 'application/json'}
        )
        
        assert response.status_code == 201
        response_data = response.json()
        assert 'id' in response_data
        assert response_data['name'] == user_data['name']
    
    def test_get_user_by_id(self):
        user_id = 1
        response = requests.get(f"{self.base_url}/users/{user_id}")
        
        assert response.status_code == 200
        user_data = response.json()
        assert user_data['id'] == user_id
    
    def test_update_user(self):
        user_id = 1
        update_data = {"email": "newemail@example.com"}
        
        response = requests.patch(
            f"{self.base_url}/users/{user_id}",
            json=update_data
        )
        
        assert response.status_code == 200
        assert response.json()['email'] == update_data['email']
    
    def test_delete_user(self):
        user_id = 1
        response = requests.delete(f"{self.base_url}/users/{user_id}")
        
        assert response.status_code == 204
        
        # Verify deletion
        get_response = requests.get(f"{self.base_url}/users/{user_id}")
        assert get_response.status_code == 404
```

## GraphQL API Testing

### GraphQL Queries and Mutations
```javascript
// GraphQL Query Testing
const query = `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        title
        content
      }
    }
  }
`;

const variables = { id: "1" };

fetch('/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query, variables })
})
.then(response => response.json())
.then(data => {
  console.log(data);
});

// GraphQL Mutation Testing
const mutation = `
  mutation CreateUser($input: UserInput!) {
    createUser(input: $input) {
      id
      name
      email
    }
  }
`;

const mutationVariables = {
  input: {
    name: "John Doe",
    email: "john@example.com"
  }
};
```

### GraphQL Testing with Jest
```javascript
const { graphql } = require('graphql');
const schema = require('../schema');

describe('GraphQL API', () => {
  test('should fetch user by id', async () => {
    const query = `
      query {
        user(id: "1") {
          id
          name
          email
        }
      }
    `;
    
    const result = await graphql(schema, query);
    
    expect(result.errors).toBeUndefined();
    expect(result.data.user).toBeDefined();
    expect(result.data.user.id).toBe("1");
  });
  
  test('should create new user', async () => {
    const mutation = `
      mutation {
        createUser(input: {name: "John", email: "john@example.com"}) {
          id
          name
          email
        }
      }
    `;
    
    const result = await graphql(schema, mutation);
    
    expect(result.errors).toBeUndefined();
    expect(result.data.createUser.name).toBe("John");
  });
});
```

## API Contract Testing

### OpenAPI/Swagger Testing
```yaml
# OpenAPI Specification
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users:
    get:
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserInput'
      responses:
        '201':
          description: User created
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
```

### Schema Validation Testing
```javascript
// JSON Schema Validation
const Ajv = require('ajv');
const addFormats = require('ajv-formats');

const ajv = new Ajv();
addFormats(ajv);

const userSchema = {
  type: 'object',
  properties: {
    id: { type: 'integer' },
    name: { type: 'string', minLength: 1 },
    email: { type: 'string', format: 'email' }
  },
  required: ['id', 'name', 'email'],
  additionalProperties: false
};

test('API response should match schema', async () => {
  const response = await fetch('/api/users/1');
  const data = await response.json();
  
  const validate = ajv.compile(userSchema);
  const valid = validate(data);
  
  if (!valid) {
    console.log(validate.errors);
  }
  
  expect(valid).toBe(true);
});
```

## Performance Testing for APIs

### Load Testing APIs
```javascript
// k6 API Load Test
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 20 },
    { duration: '30s', target: 0 },
  ],
};

export default function() {
  // Test GET endpoint
  let getResponse = http.get('http://api.example.com/users');
  check(getResponse, {
    'GET status is 200': (r) => r.status === 200,
    'GET response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  // Test POST endpoint
  let postData = JSON.stringify({
    name: 'Test User',
    email: 'test@example.com'
  });
  
  let postResponse = http.post('http://api.example.com/users', postData, {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(postResponse, {
    'POST status is 201': (r) => r.status === 201,
    'POST response time < 1000ms': (r) => r.timings.duration < 1000,
  });
}
```

## API Security Testing

### Authentication Testing
```bash
# JWT Token Testing
# Test with invalid token
curl -H "Authorization: Bearer invalid_token" \
  http://api.example.com/protected

# Test with expired token
curl -H "Authorization: Bearer expired_token" \
  http://api.example.com/protected

# Test without token
curl http://api.example.com/protected
```

### Input Validation Testing
```python
# API Input Validation Tests
def test_sql_injection_protection():
    malicious_input = "'; DROP TABLE users; --"
    response = requests.post('/api/users', json={
        'name': malicious_input,
        'email': 'test@example.com'
    })
    
    # Should not execute SQL injection
    assert response.status_code in [400, 422]

def test_xss_protection():
    xss_payload = "<script>alert('XSS')</script>"
    response = requests.post('/api/users', json={
        'name': xss_payload,
        'email': 'test@example.com'
    })
    
    # Should sanitize or reject XSS payload
    if response.status_code == 201:
        user_data = response.json()
        assert '<script>' not in user_data['name']
```

## CI/CD Integration

### API Testing Pipeline
```yaml
# GitHub Actions API Testing
name: API Tests
on: [push, pull_request]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Start API server
        run: npm start &
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
      
      - name: Wait for API
        run: npx wait-on http://localhost:3000/health
      
      - name: Run API tests
        run: npm run test:api
      
      - name: Run Postman tests
        run: newman run postman-collection.json -e test-environment.json
```