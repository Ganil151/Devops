# Production Compose Challenges 🚀

Master scaling, load balancing, and zero-downtime deployments with these advanced labs.

---

## 🏆 Challenge 01: The Horizontal Scale-Out
**Objective**: Handle a sudden traffic spike by multiplying your application instances.

1.  **Requirement**: Create a `docker-compose.yml` with a `web` service (use `nginx:alpine`).
2.  **Constraint**: Do NOT map a host port in the `web` service (e.g., use `expose: ["80"]` instead of `ports: ["80:80"]`).
3.  **Task**: Start the stack and scale the `web` service to **5 instances** using the `--scale` flag.
4.  **Verification**: Run `docker ps` to verify all 5 containers are running with unique IDs.

---

## 🏆 Challenge 02: Load Balancer Integration
**Objective**: Distribute traffic across your scaled instances.

1.  **Requirement**: Add a `loadbalancer` service using the `nginx` image to your Compose file.
2.  **Task**: Configure the Nginx container to act as a reverse proxy that forwards traffic to the `web` service name.
3.  **Goal**: Access `localhost:8080` on your machine and see it load specific web instances.
4.  **Proof of Success**: Kill one `web` container manually and verify the site still loads via the load balancer.

---

## 🏆 Challenge 03: Health-Aware Orchestration
**Objective**: Ensure your load balancer only sends traffic to "Healthy" containers.

1.  **Requirement**: Add a `healthcheck` to your `web` service in the Compose file.
2.  **Task**: 
    *   Command: `curl -f http://localhost/ || exit 1`
    *   Interval: `10s`
    *   Retries: `3`
3.  **Experiment**: Simulate a failure by manually deleting the `index.html` inside one of the web containers.
4.  **Observation**: Run `docker ps` and watch the status change from `(healthy)` to `(unhealthy)`.

---

## 📁 Solutions
Reference Compose templates are available in the `Boilerplates/` directory.
