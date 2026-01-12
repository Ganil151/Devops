# SonarQube Configuration

Essential configuration guides for optimizing SonarQube performance, security, and functionality.

## Configuration Areas

### Database Configuration
- **PostgreSQL Setup**: Optimal database configuration for SonarQube
- **Connection Pooling**: Database connection optimization
- **Performance Tuning**: Database-specific performance improvements
- **Backup Strategies**: Database backup and recovery procedures

### Security Configuration  
- **Authentication**: LDAP, SAML, OAuth integration
- **Authorization**: User roles and permissions
- **SSL/TLS**: Secure communication setup
- **Network Security**: Firewall and proxy configuration

### Performance Configuration
- **JVM Tuning**: Memory and garbage collection optimization
- **System Resources**: CPU, memory, and storage optimization
- **Caching**: Application-level caching strategies
- **Monitoring**: Performance metrics and alerting

## Quick Configuration Checklist

### Initial Setup
```bash
# 1. Database connection
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
sonar.jdbc.username=sonar
sonar.jdbc.password=secure_password

# 2. Web server settings
sonar.web.host=0.0.0.0
sonar.web.port=9000

# 3. JVM memory settings
sonar.web.javaAdditionalOpts=-Xmx4G -Xms2G
sonar.search.javaOpts=-Xmx2G -Xms2G
```

### Security Hardening
```bash
# 4. Force authentication
sonar.forceAuthentication=true

# 5. Enable HTTPS
sonar.web.https.port=9443
sonar.web.https.keyStore=/path/to/keystore.p12

# 6. Session security
sonar.web.sessionTimeoutInMinutes=60
```

### Performance Optimization
```bash
# 7. System limits
vm.max_map_count=524288
fs.file-max=131072

# 8. Database pool
sonar.jdbc.maxActive=60
sonar.jdbc.maxIdle=5
```

## Configuration Files

### Main Configuration
- **sonar.properties**: Primary configuration file
- **wrapper.conf**: Service wrapper configuration (if using)
- **logback.xml**: Logging configuration

### Environment-Specific
- **Development**: Relaxed security, H2 database acceptable
- **Staging**: Production-like setup with monitoring
- **Production**: Full security, PostgreSQL, monitoring, backup

## Common Configuration Patterns

### High Availability Setup
```properties
# Load balancer configuration
sonar.cluster.enabled=true
sonar.cluster.node.type=application
sonar.cluster.hosts=node1:9003,node2:9003
```

### Multi-Environment Setup
```properties
# Environment-specific properties
sonar.projectKey.prefix=${ENVIRONMENT}
sonar.web.context=/${ENVIRONMENT}/sonar
```

### Integration Configuration
```properties
# CI/CD integration
sonar.webhooks.global=http://jenkins:8080/sonarqube-webhook/
sonar.auth.github.enabled=true
sonar.auth.gitlab.enabled=true
```

## Troubleshooting Configuration

### Common Issues
- **Database Connection**: Check JDBC URL and credentials
- **Memory Issues**: Adjust JVM heap settings
- **Permission Errors**: Verify file system permissions
- **Network Issues**: Check firewall and proxy settings

### Validation Commands
```bash
# Test database connection
psql -h localhost -U sonar -d sonarqube -c "SELECT version();"

# Check SonarQube status
curl http://localhost:9000/api/system/status

# Verify JVM settings
ps aux | grep sonar | grep -o '\-Xm[sx][0-9]*[gGmM]'
```

## Best Practices

1. **Use Environment Variables**: For sensitive configuration values
2. **Version Control**: Track configuration changes
3. **Documentation**: Document custom configurations
4. **Testing**: Test configuration changes in staging first
5. **Monitoring**: Monitor configuration impact on performance