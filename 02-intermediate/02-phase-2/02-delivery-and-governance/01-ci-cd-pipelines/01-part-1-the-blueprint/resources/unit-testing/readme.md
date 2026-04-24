# Unit Testing

Complete guide to unit testing practices, frameworks, and implementation strategies.

## Unit Testing Fundamentals

### Characteristics
```bash
# Fast execution (< 1 second)
# Isolated and independent
# Repeatable and deterministic
# Self-validating
# Timely (written with or before code)
```

## JavaScript Testing

### Jest Framework
```javascript
describe('Calculator', () => {
  test('should add two numbers correctly', () => {
    const calculator = new Calculator();
    const result = calculator.add(2, 3);
    expect(result).toBe(5);
  });
});

// Mocking dependencies
jest.mock('./database');
const mockDb = require('./database');

test('should save user to database', async () => {
  mockDb.save.mockResolvedValue({ id: 1, name: 'John' });
  
  const userService = new UserService();
  const result = await userService.createUser('John');
  
  expect(mockDb.save).toHaveBeenCalledWith({ name: 'John' });
  expect(result.id).toBe(1);
});
```

## Python Testing

### pytest Framework
```python
import pytest
from unittest.mock import Mock, patch

class TestUserService:
    def test_create_user_success(self):
        user_data = {"name": "John", "email": "john@example.com"}
        result = self.user_service.create_user(user_data)
        assert result["name"] == "John"
    
    @patch('myapp.services.database')
    def test_create_user_with_mock(self, mock_db):
        mock_db.save.return_value = {"id": 1, "name": "John"}
        result = self.user_service.create_user({"name": "John"})
        assert result["id"] == 1
```

## Java Testing

### JUnit 5
```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    private Calculator calculator;
    
    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }
    
    @Test
    void shouldAddTwoPositiveNumbers() {
        int result = calculator.add(2, 3);
        assertEquals(5, result);
    }
    
    @Test
    void shouldThrowExceptionForDivisionByZero() {
        assertThrows(ArithmeticException.class, () -> {
            calculator.divide(10, 0);
        });
    }
}
```

## Coverage and CI/CD

### Coverage Commands
```bash
# JavaScript (Jest)
npm test -- --coverage

# Python (Coverage.py)
coverage run -m pytest
coverage report

# Java (JaCoCo)
mvn jacoco:report

# Go
go test -cover
```