# Enterprise Repository Settings & Governance Reference

**Doc Version:** 1.0.0
**Role:** Senior DevOps Engineer
**Scope:** Settings.xml, Proxy Repositories, and Security

---

## 1. The Global Settings (`~/.m2/settings.xml`)

The `settings.xml` file is the user-specific configuration. It contains credentials and location-aware overrides. It should **never** be committed to the repo.

### Key Components:
- **LocalRepository**: Location on disk.
- **Servers**: Credentials (Username/Encrypted Password) for remote repos.
- **Mirrors**: Rules to redirect traffic (e.g., Block Maven Central).
- **Profiles**: Environment-specific toggles.

---

## 2. Repository Management (Nexus / Artifactory)

In an enterprise, developers **never** download directly from the internet (`repo1.maven.org`).
They must go through a Proxy Repository (Single Source of Truth).

### Why?
1.  **Security**: Malicious packages can be blocked at the firewall (Nexus) level.
2.  **Speed**: Caching artifacts on the LAN limits bandwidth usage.
3.  **Stability**: If Maven Central goes down, your cached build still works.
4.  **Audit**: You know exactly what libraries entered the organization.

### The Mirror Configuration
Force all traffic to the internal proxy:
```xml
<mirrors>
    <mirror>
        <id>internal-nexus</id>
        <mirrorOf>*</mirrorOf>
        <url>https://nexus.company.com/repository/maven-public/</url>
    </mirror>
</mirrors>
```
*Note: `mirrorOf *` is aggressive. It captures everything.*

---

## 3. Password Encryption

**Never store plain text passwords in `settings.xml`.**

Maven provides a native encryption mechanism.
1.  Generate a Master Password: `mvn --encrypt-master-password <password>`
2.  Store in `~/.m2/settings-security.xml`.
3.  Encrypt Server Password: `mvn --encrypt-password <password>`
4.  Store in `settings.xml`.

---

## 4. Snapshot vs. Release Policy

### Snapshots
- **Mutable**: `1.0-SNAPSHOT` can change 50 times in an hour.
- **Dev Only**: Maven checks for updates daily (or on forced update `-U`).
- **Policy**: Never deploy to Production.

### Releases
- **Immutable**: `1.0.0` is written in stone. Once deployed to Nexus, it cannot be overwritten (Nexus prevents redeployment).
- **Prod Ready**: Cryptographically signed and verified.

---

## 5. Security & Governance Checklist

- [ ] **Block HTTP**: Only allow HTTPS connections in `settings.xml`.
- [ ] **Checksum Policy**: Set `<checksumPolicy>fail</checksumPolicy>` to prevent corrupted artifacts.
- [ ] **Separate Repos**: Use separate Nexus repositories for Third-Party (Proxy) and Internal (Hosted) artifacts.
