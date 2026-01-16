# Call Center CRM: Full-Stack DevOps Project

This is a comprehensive real-world project demonstrating a full-stack CRM (Customer Relationship Management) system designed for call center operations. It showcases the integration of multiple tiers including a React frontend, Python backend, and automated deployment.

---

## 🏭 Architecture

### 1. Frontend (React.js)
The frontend provides a real-time dashboard for agents and managers.
- **Dashboard**: Real-time stats on calls and ticket status.
- **Call Logs**: Detailed history and notes.
- **Analytics**: Charts and graphs using `Chart.js`.

### 2. Backend (Python/Django)
A robust REST API that handles data persistence and business logic.
- **Models**: Management of Agents, Customers, and Tickets.
- **Authentication**: Secure JWT-based user login.
- **API Docs**: Swagger/OpenAPI integration.

### 3. Database
- **PostgreSQL**: Used for reliable, relational data storage.

---

## 🛠️ DevOps & Deployment

- **Containerization**: Every service is Dockerized for consistency across Dev, Staging, and Production.
- **CI/CD**: Prepared for GitHub Actions or GitLab CI/CD pipelines.
- **Orchestration**: Ready to be deployed on Kubernetes (EKS) using the provided Helm charts.

---

## 🚀 Getting Started

1. **Prerequisites**: Install Docker and Docker Compose.
2. **Setup**: Run `docker-compose up --build` to launch the entire stack.
3. **Access**:
   - Frontend: `http://localhost:3000`
   - API Docs: `http://localhost:8000/docs`

---
**Advanced**: Learn how to monitor this application's performance in the [Observability Hub](../../../README.md).
