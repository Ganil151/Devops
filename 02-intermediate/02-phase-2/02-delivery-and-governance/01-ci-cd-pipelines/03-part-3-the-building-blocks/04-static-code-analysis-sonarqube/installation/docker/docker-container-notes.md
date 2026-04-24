# 

Your command is:
```bash
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

That will start SonarQube in a container and expose it on http://localhost:9000
.
But there are a few important notes 👇

🔧 Issues / Improvements
## 1. SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true

This disables Elasticsearch bootstrap checks — useful for dev/testing, but unsafe for production.
In production you should configure proper VM settings (e.g., vm.max_map_count).

For local/dev testing → it’s fine 👍

----

## 2. Data persistence

By default, everything (config, data, logs, plugins) is stored inside the container. If the container is removed, you lose all data.
Better: mount volumes:
```bash
docker run -d --name sonarqube \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:latest

```
This way data survives container restarts.
----

## 3. Database (important ⚠️)

SonarQube does not support H2 for production.
If you use sonarqube:latest without extra config, it will start with the embedded H2 DB, which is only for demo.

For real usage, you must connect to PostgreSQL:
```bash
docker run -d --name sonarqube \
  -e SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonarpass \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:latest

```

(where db is a PostgreSQL container or RDS instance).

You also need to create the DB and user in PostgreSQL:

```sql
CREATE DATABASE sonarqube;
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonarpass';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
```
----  

## 4. Recommended way: Docker Compose

Instead of a long docker run, you can manage both SonarQube + PostgreSQL with docker-compose.yml:

version: "3"
```yml
services:
  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonarpass
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    depends_on:
      - db

  db:
    image: postgres:15
    container_name: sonarqube_db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonarpass
      POSTGRES_DB: sonarqube
    volumes:
      - postgresql:/var/lib/postgresql

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:

```
Then run:
```bash
docker compose up -d
```

✅ Summary:

Your command works for a quick test with H2.

For persistence → mount volumes.

For production → connect to PostgreSQL (Docker Compose is easiest).

👉 Do you want me to generate a ready-to-use Docker Compose file for SonarQube + PostgreSQL on your EC2 (with ports, volumes, and DB preconfigured)?