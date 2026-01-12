# 02: Authentication and JWT

Securing APIs is primarily about ensuring that only authorized users can access specific resources. In microservices, **JSON Web Tokens (JWT)** and **OAuth2/OIDC** are the industry standards.

## 🎫 JSON Web Tokens (JWT)

A JWT is a compact, URL-safe way of representing claims to be transferred between two parties.

### JWT Structure
A JWT consists of three parts separated by dots (`.`):
1. **Header**: Contains the type of token (JWT) and the signing algorithm (e.g., HS256, RS256).
2. **Payload**: Contains the "claims" (data), like `user_id`, `email`, and `exp` (expiration time).
3. **Signature**: Created by taking the encoded header, the encoded payload, a secret/key, and the algorithm.

### How it works in DevOps:
- The Gateway intercepts the request.
- It validates the JWT signature using a shared secret or a public key.
- If valid, it forwards the request (often adding the user info as a header like `X-User-ID`).

---

## 🔒 OAuth2 and OpenID Connect (OIDC)

### OAuth2 Roles:
- **Resource Owner**: The User.
- **Resource Server**: The API holding the data.
- **Client**: The app requesting access.
- **Authorization Server**: The server issuing tokens (e.g., Keycloak, Auth0, Okta).

### Common Flows:
- **Authorization Code Flow**: Used for web apps (most secure).
- **Client Credentials**: Used for machine-to-machine communication (e.g., microservice A talking to microservice B).

---

## 🛡️ Security Best Practices

1. **HTTPS Only**: Never transmit tokens over unencrypted channels.
2. **Short-Lived Access Tokens**: Minimize the window of risk if a token is stolen.
3. **Refresh Tokens**: Use long-lived refresh tokens to get new access tokens without re-logging.
4. **Scope Limiting**: Don't give "Admin" permissions by default. Use granular scopes.
5. **Token Revocation**: Implement a blacklist or use short TTLs to handle logout/security breaches.
