# Artifact Registry Challenges 📦

Practice managing the binaries that power your infrastructure.

---

## 🏆 Challenge 01: Local Nexus Setup
**Objective**: Spin up your own private "Universal" artifact server.

1.  **Task**: Use the `docker-compose-nexus.yml` boilerplate.
2.  **Steps**:
    *   Run `docker-compose up -d`.
    *   Find the initial password (hint: it's inside the container at `/nexus-data/admin.password`).
    *   Log in at `http://localhost:8081`.
3.  **Verification**: Take a screenshot of the "Repositories" dashboard.

---

## 🏆 Challenge 02: Pushing a Python Artifact (Simulated)
**Objective**: Understand the workflow of "Packaging and Publishing."

1.  **Task**: Create a dummy Python package.
2.  **Steps**:
    *   Create a folder `my_package` with an `__init__.py`.
    *   Create a `setup.py` (use a search for a standard template).
    *   **Goal**: Research what command is used to "build" the package into a `.whl` (wheel) file.
3.  **Questions**: What tool is typically used to upload these wheels to a registry like Artifactory or PyPI?

---

## 🏆 Challenge 03: The Retention Policy
**Objective**: prevent disk exhaustion.

1.  **Scenario**: Your build server creates 10 artifacts a day. After a year, the disk is full.
2.  **Research Task**: Find out what a "Retention Policy" (or Cleanup Policy) is in Sonatype Nexus.
3.  **Lab**: Configure a policy that keeps only the last 5 versions of any artifact.

---

## 📁 Solutions
Templates for deployment are in the `Boilerplates/` directory.
