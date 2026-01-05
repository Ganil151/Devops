# 02: Smart Contract CI/CD

In DevOps, we treat Smart Contracts like any other code. Every push should trigger a pipeline that validates, tests, and optionally deploys the code to a testnet.

## 🚀 The Web3 Pipeline

A standard CI/CD pipeline for a blockchain project includes:

1.  **Linting**: Ensuring the Solidity code follows the style guide (using `solhint`).
2.  **Compilation**: Verifying the code compiles correctly.
3.  **Unit Testing**: Running thousands of tests to ensure logic is flawless (Critical because code is immutable once deployed).
4.  **Security Scans**: Running static analysis tools (Slither).
5.  **Deployment**: Automating the push to a Testnet (Sepolia) or Mainnet.

---

## 🛠️ GitHub Actions Template (Foundry)

```yaml
name: Smart Contract CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
      
      - name: Compile & Test
        run: forge test -vv
```

---

## 🔑 Managing Private Keys

The most sensitive part of Blockchain DevOps is managing the **Private Key** used for deployments.

- **NEVER** hardcode private keys in scripts or `.env` files.
- **GitHub Secrets**: Store your deployment key in an encrypted GitHub Secret.
- **Vaults**: Use HashiCorp Vault or AWS Secrets Manager for production deployments.
- **KMS**: Use Cloud KMS (Key Management Service) to sign transactions without ever touching the raw private key.
