# Database Storage in Docker Compose

When running databases in Docker, understanding **where** they store data is critical for persistence. This guide provides the exact configuration paths and best practices for the most popular database images.

## Quick Reference: Internal Data Paths

| Database | Data Directory (Inside Container) | Initialization Directory |
| :--- | :--- | :--- |
| **PostgreSQL** | `/var/lib/postgresql/data` | `/docker-entrypoint-initdb.d/` |
| **MySQL / MariaDB** | `/var/lib/mysql` | `/docker-entrypoint-initdb.d/` |
| **MongoDB** | `/data/db` | `/docker-entrypoint-initdb.d/` |
| **Redis** | `/data` | N/A (Config based) |
| **InfluxDB** | `/var/lib/influxdb2` | `/docker-entrypoint-initdb.d/` |

---

## 1. PostgreSQL
Postgres is very strict about permissions. Always use **Named Volumes** for the data directory.

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      # Named volume for persistence
      - pgdata:/var/lib/postgresql/data
      # Bind mount for auto-running SQL scripts on startup
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro

volumes:
  pgdata:
```

---

## 2. MySQL / MariaDB
Similar to Postgres, MySQL uses an initialization directory for setup scripts.

```yaml
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
    volumes:
      - mysql_data:/var/lib/mysql
      - ./my_custom.cnf:/etc/mysql/conf.d/my_custom.cnf:ro

volumes:
  mysql_data:
```

---

## 3. MongoDB
MongoDB perform best when using the default `wiredTiger` storage engine. Ensure your host machine has enough disk space and avoids network filesystems (like NFS) for the data path if possible.

```yaml
services:
  mongodb:
    image: mongo:latest
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

---

## 4. Redis
By default, Redis is mostly in-memory. To survive restarts, you must enable **AOF (Append Only File)** or **RDB (Snapshotting)**.

```yaml
services:
  cache:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

---

## 5. SQLite
SQLite is different because it is just a **file**, not a running server. It should usually be handled via a **Bind Mount** so the file lives directly in your project folder.

```yaml
services:
  app:
    image: my-python-app
    volumes:
      - ./data/app.db:/app/database.sqlite
```

---

## Best Practices for DB Storage

1. **Named Volumes for Data**: Use named volumes for the main data directory (`/var/lib/...`) to benefit from Docker's managed storage.
2. **Init Scripts**: Use the `/docker-entrypoint-initdb.d/` folder to automatically create tables or seed data the **first** time the volume is created.
3. **Read-Only Configs**: Mount your database configuration files (like `my.cnf` or `postgresql.conf`) as `:ro` (Read-Only).
4. **Environment Variables**: Use `.env` files to store sensitive credentials like `POSTGRES_PASSWORD`.
5. **Backup Pattern**: Periodically run a "sidecar" container or a `docker exec` command to dump the database to a host-mounted backup folder.

---

**[Back to Home](../../README.md)**
