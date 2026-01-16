# Terraform Console

The `terraform console` command provides an interactive console for evaluating expressions. This is extremely useful for testing interpolations and debugging values before applying them in your configuration.

## Usage

```bash
terraform console [options]
```

## Common Use Cases

### 1. Mathematical Calculations
Test Terraform's built-in math functions:

```hcl
> 1 + 5
6
> max(5, 12, 9)
12
```

### 2. Testing String Interpolation
Verify how your string templates will render:

```hcl
> "Hello, ${var.name}!"
"Hello, World!"
```

### 3. Inspecting State Values
Access the current state to check attribute values of resources:

```hcl
> aws_instance.web.public_ip
"1.2.3.4"
> var.region
"us-east-1"
```

### 4. Debugging Complex logic
Test conditionals and loops:

```hcl
> local.is_production ? "t2.large" : "t2.micro"
"t2.micro"
```

## Key Features

- **Read-Only**: The console is read-only and will never modify your state or infrastructure.
- **State Aware**: It has access to the current state file (if initialized).
- **Interpolation Testing**: Perfect for `cidrip()`, `format()`, and other complex functions.
