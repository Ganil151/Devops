# 🐳 Foundational Containers: Docker Mastery

> **"Learn to walk before you run. Learn to Dockerize before you Orchestrate. Docker is the universal packaging format for the cloud."**

---

## 🏗️ Images vs. Containers: The Golden Rule
Understanding the distinction is the first step toward container zen.

| Component | Analogy | DevOps Why |
| :--- | :--- | :--- |
| **Dockerfile** | The Recipe | Version-controlled instructions for your environment. |
| **Image**| The Frozen Meal | The static, immutable artifact ready for deployment. |
| **Container** | The Cooked Meal | The live, running instance of your application. |

---

## 🚀 The DevOps Why: Immutable Infrastructure
> **Senior Tip**: In the old days, we patched servers (Snowflakes). In the Docker era, we never patch a running container. We update the `Dockerfile`, rebuild the **Image**, and replace the **Container**. This ensures "It works on my machine" translates perfectly to "It works in production."

---

## 🛠️ The Docker Toolbelt (Essential Commands)
| Command | Purpose | Junior Tip |
| :--- | :--- | :--- |
| `docker build -t app:v1 .` | Build Image | Always tag your images with a version, never just `latest`. |
| `docker run -p 80:80` | Start Container | Mapping ports is how you expose your app to the world. |
| `docker logs -f <id>` | Debugging | The first place to check if your container crashes on start. |
| `docker exec -it <id> bash` | Inspection | Dropping into a running container to verify file paths. |

---

## 📂 Module Structure

1. **[01-Docker-Basics](./01-docker-basics/01-introduction/readme.md)**: Architecture and Engine internals.
2. **[02-Images-Containers](./01-docker-basics/02-images-and-containers/readme.md)**: Mastering the Lifecycle.
3. **[03-Dockerfile-Basics](./01-docker-basics/03-dockerfile-basics/readme.md)**: Writing efficient recipes.
4. **[04-Debugging](./01-docker-basics/04-debugging/readme.md)**: SRE Inspection techniques.

---

**Next Step**: Start with [01-Introduction](./01-docker-basics/01-introduction/readme.md)
