# 🐳 Container Orchestration: Hands-On Challenges

Master the lifecycle of applications by completing these 10 progressive challenges.

## 🟢 Level: Beginner (The Sandbox)

### Challenge 01: The Static Host

- **Task**: Run an official `nginx` container in detached mode.
- **Goal**: Map host port `8080` to container port `80`.
- **Success Criteria**: Visit `http://localhost:8080` and see the "Welcome to nginx!" page.

### Challenge 02: Image Interrogation

- **Task**: Pull the `alpine` image and run a container that executes `echo "Hello DevOps"`.
- **Goal**: The container should exit immediately after printing.
- **Success Criteria**: Check `docker ps -a` to find the exited container and verify the status code is `0`.

### Challenge 03: The Custom Blueprint

- **Task**: Create a `Dockerfile` for a simple HTML page using Nginx.
- **Goal**: Copy an `index.html` file into the container during the build.
- **Success Criteria**: Build the image as `my-website:v1` and run it.

---

## 🟡 Level: Intermediate (The Developer)

### Challenge 04: Layer Optimization

- **Task**: Take a "Large" Dockerfile (e.g., using `FROM ubuntu`) and optimize it using `alpine`.
- **Goal**: Reduce the image size by at least 50%.
- **Success Criteria**: Compare `docker images` sizes between the two versions.

### Challenge 05: Persistent Database

- **Task**: Run a `postgres` container with a persistent volume.
- **Goal**: Mount a local folder to `/var/lib/postgresql/data`.
- **Success Criteria**: Stop the container, remove it, start a new one with the same volume, and verify your data is still there.

### Challenge 06: The Python Package

- **Task**: Dockerize a simple Flask application.
- **Goal**: Use a `requirements.txt` file and ensure the application runs on port `5000`.
- **Success Criteria**: Use `docker exec -it` to enter the running container and check the environment variables.

---

## 🔴 Level: Advanced (The Architect)

### Challenge 07: The 3-Tier Orchestra

- **Task**: Create a `docker-compose.yml` file for a "Voting App" (Frontend + Redis + Worker + DB).
- **Goal**: Ensure the services can communicate using custom networks.
- **Success Criteria**: Run `docker compose up -d` and verify all services reach "Healthy" state.

### Challenge 08: Multi-Stage Mastery

- **Task**: Build a Go or Java application using a multi-stage `Dockerfile`.
- **Goal**: Use a heavy build image and a tiny `distroless` or `scratch` runtime image.
- **Success Criteria**: The final production image should not contain any build tools (compilers, git, etc.).

### Challenge 09: Production Hardening

- **Task**: Take an existing image and update the `Dockerfile` to run as a non-root user.
- **Goal**: Use the `USER` instruction and ensure permissions are correct for the app directory.
- **Success Criteria**: Run `docker exec <id> whoami` and see a name other than `root`.

### Challenge 10: The Health Check

- **Task**: Add a `HEALTHCHECK` instruction to an Nginx Dockerfile.
- **Goal**: The check should use `curl` to verify the internal status page every 30 seconds.
- **Success Criteria**: Run the container and observe the status change from `starting` to `healthy` in `docker ps`.

---

## 💡 Stuck?

- Review the [Master README](./readme.md) for concepts.
- Check the [Docker Documentation](readme.md) for more examples.
- Use `docker system prune` to clean up your workspace between challenges.

**Good luck, Container Architect!**
