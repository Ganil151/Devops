### Webhook Configuration
Added the triggers block with githubPush() to enable automatic builds triggered by GitHub webhooks.
To set up the webhook:
Go to your GitHub repository settings.
Navigate to Webhooks > Add Webhook.
Set the Payload URL to your Jenkins server's webhook endpoint (e.g., http://<jenkins-server>/github-webhook/).
Select Content type as application/json.
Save the webhook.
2. Removed Docker Commands
Removed all Docker-specific commands (docker compose build, docker compose up -d, etc.) since Docker is no longer used.
Instead, the pipeline now focuses on building and testing the application directly.
3. Maven Build and Test
Used Maven (./mvnw) to build and test the application:
./mvnw clean package -DskipTests: Builds the application without running tests.
./mvnw test: Runs unit tests.
4. Deployment Step
Added a placeholder for deploying the application to a test environment. You can customize this step based on your deployment process (e.g., copying files to a server, uploading to AWS S3, etc.).
5. Post-Build Actions
Added cleanWs() in the post block to clean up the workspace after the build.
Added success and failure notifications for better visibility.
Steps to Configure Jenkins
Install Required Plugins
Ensure the following plugins are installed:
Pipeline
Git Plugin
Workspace Cleanup Plugin (for cleanWs())
Create a Multibranch Pipeline
Create a multibranch pipeline job in Jenkins.
Configure the repository URL and credentials.
Enable the GitHub hook trigger for GITScm polling option.
Set Up Webhook
Follow the steps mentioned above to configure the GitHub webhook.
Run the Pipeline
Push changes to the repository, and the webhook will trigger the pipeline automatically.
Advantages of This Approach
No Dependency on Docker: Simplifies the pipeline by removing Docker, making it easier to manage and debug.
Automated Builds: Webhooks ensure that builds are triggered automatically whenever changes are pushed to the repository.
Focus on Core Build Process: The pipeline focuses on building, testing, and deploying the application without unnecessary complexity.
Let me know if you need further assistance!

### 
```bash
sudo -u jenkins ssh-keyscan -H <WORKER-IP> | sudo tee -a /var/lib/jenkins/.ssh/known_hosts > /dev/null
```
