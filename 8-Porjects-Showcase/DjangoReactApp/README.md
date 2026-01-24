# Django & Next.js Backend API Boilerplate

This project demonstrates a modern, high-performance architecture using Django (Python) for a robust REST API and Next.js (React) for a highly responsive, server-side rendered frontend.

---

## 🏗️ Technical Stack

### Backend: Django & Django-Ninja
- **Framework**: Django 5.x.
- **API Engine**: Django-Ninja for type-safe, high-performance REST APIs.
- **REST Framework**: Django Rest Framework (DRF) for standard API patterns.
- **CORS**: Configured using `django-cors-headers` for secure cross-origin requests.

### Frontend: Next.js (React)
- **Framework**: Next.js (App Router).
- **Styling**: Material UI (MUI) and Tailwind CSS.
- **State Management**: React Context/Hooks.

---

## 🚀 Build & Development

### 1. Backend Setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8001
```

### 2. Frontend Setup
```bash
npx create-next-app@latest
npm install @mui/material @emotion/react @emotion/styled
npm run dev
```

---

## 🛠️ Key Components
- **Navbar**: A responsive sidebar/drawer built with Material UI for easy navigation.
- **API Integration**: Context-aware API calls using `fetch` or `axios` from the Next.js frontend to the Django backend.
- **Security**: JWT-based authentication and CORS allowance for specific frontend origins.

---
**Learning Integration**: This project is an excellent example of the [Intermediate Automation](../../README.md) and [Advanced Microservices](../../README.md) modules.
