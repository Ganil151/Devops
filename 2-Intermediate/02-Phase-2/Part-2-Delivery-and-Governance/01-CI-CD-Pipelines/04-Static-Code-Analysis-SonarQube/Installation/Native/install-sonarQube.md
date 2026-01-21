How to Install SonarQube on Ubuntu 24.04

Learn to install SonarQube on Ubuntu 24.04, enhancing code quality and security with detailed insights and static analysis.
How to Install SonarQube on Ubuntu 24.04 header image
SonarQube is an open-source platform used to continuously inspect code quality and manage code quality. It detects bugs, vulnerabilities, and tracks code quality through static analysis with detailed reports. SonarQube supports multiple programming languages and improves code quality, maintainability, and security by offering actionable insights with two editions, community and enterprise.

This article explains how to Install SonarQube on Ubuntu 24.04. You will install SonarQube and use it to inspect code quality with example projects on your workstation.

Prerequisites
Before you begin, you need to:

Have access to an Ubuntu 24.04 instance as a non-root sudo user.
Set Up a PostgreSQL Database for SonarQube
SonarQube requires a PostgreSQL database to store data. PostgreSQL is available in the default package repositories on Ubuntu. Follow the steps below to install PostgreSQL and create a new database to use with SonarQube.

Install the PostgreSQL if it's not installed on your Ubuntu 24.04 workstation.
```bash
$ sudo apt install -y postgresql-common postgresql -y
```
Enable the PostgreSQL database server to automatically start at boot.
```bash
$ sudo systemctl enable postgresql
```

Output:
```bash
Synchronizing state of postgresql.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable postgresql
```

Start the PostgreSQL database server.
```bash
$ sudo systemctl start postgresql
```
Log in to the PostgreSQL database server as the postgres user.

console
Copy
$ sudo -u postgres psql
Explain Code
Create a new sonaruser PostgreSQL role with a strong password to use with SonarQube. Replace your_password with your desired password.

psql
Copy
postgres=# CREATE ROLE sonaruser WITH LOGIN ENCRYPTED PASSWORD 'your_password';
Explain Code
Create a new sonarqube database.

psql
Copy
postgres=# CREATE DATABASE sonarqube;
Explain Code
Grant the sonaruser role full privileges to the sonarqube database.

psql
Copy
postgres=# GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonaruser;
Explain Code
Switch to the sonarqube database.

psql
Copy
postgres=# \c sonarqube
Explain Code
Output:

You are now connected to database "sonarqube" as user "postgres".
Grant the sonaruser role full privileges to the public schema.

psql
Copy
postgres=# GRANT ALL PRIVILEGES ON SCHEMA public TO sonaruser;
Explain Code
Exit the PostgreSQL database console.

psql
Copy
postgres=# \q
Explain Code
Install SonarQube
SonarQube is not available in the default package repositories on Ubuntu 24.04 and requires OpenJDK 17 to run. Follow the steps below to download the latest SonarQube release file and install SonarQube.

Update the server's APT package index.

console
Copy
$ sudo apt update
Explain Code
Install OpenJDK 17.

console
Copy
$ sudo apt install openjdk-17-jdk -y
Explain Code
Install Unzip to extract files from the SonarQube archive.

console
Copy
$ sudo apt install unzip
Explain Code
Verify the installed java version.

console
Copy
$ java -version
Explain Code
Your output should be similar to the one below:

openjdk version "17.0.14" 2025-01-21
OpenJDK Runtime Environment (build 17.0.14+7-Ubuntu-124.04)
OpenJDK 64-Bit Server VM (build 17.0.14+7-Ubuntu-124.04, mixed mode, sharing)
Visit the SonarQube releases page and verify the latest version to download. For example, sonarqube-25.2.0.102705.zip.

Download the latest SonarQube archive.

console
Copy
$ sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.2.0.102705.zip
Explain Code
Extract files from the downloaded archive using Unzip.

console
Copy
$ unzip sonarqube-25.2.0.102705.zip
Explain Code
Move the extracted files to a systemwide directory such as /opt.

console
Copy
$ sudo mv sonarqube-25.2.0.102705/ /opt/sonarqube
Explain Code
Create a dedicated sonarqube system user without login privileges and a home directory.

console
Copy
$ sudo adduser --system --no-create-home --group --disabled-login sonarqube
Explain Code
Grant the sonarqube user full privileges to the /opt/sonarqube directory.

console
Copy
$ sudo chown -R sonarqube:sonarqube /opt/sonarqube
Explain Code
Install SonarScanner CLI
SonarQube uses code scanners depending on the target programming language to scan and analyze code quality. SonarScanner CLI is the default scanner if no specific scanner is specified on your system. Follow the steps below to install the SonarScanner CLI to analyze code on your workstation.

Visit the SonarScanner CLI page and verify the latest version to download. For example, run the following command to download the SonarScanner CLI version 7.0.1

console
Copy
$ wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-7.0.1.4817-linux-x64.zip
Explain Code
Extract files from the archive depending on the downloaded version.

console
Copy
$ unzip sonar-scanner-cli-7.0.1.4817-linux-x64.zip
Explain Code
Move the extracted directory to /opt/sonarscanner.

console
Copy
$ sudo mv sonar-scanner-7.0.1.4817-linux-x64/  /opt/sonarscanner
Explain Code
Open the sonar-scanner.properties configuration file.

console
Copy
$ sudo nano /opt/sonarscanner/conf/sonar-scanner.properties
Explain Code
Find the following sonar.host.url directive and change the default https://mycompany.com/sonarqube value to 127.0.0.1.

ini
Copy
...
sonar.host.url=127.0.0.1
...
Explain Code
Save and close the file.

The above Sonar Host directive specifies the SonarQube server URL to use while performing code scans.

Enable execute permissions on the sonar-scanner binary.

console
Copy
$ sudo chmod +x /opt/sonarscanner/bin/sonar-scanner
Explain Code
Link the sonar-scanner binary to the /usr/local/bin directory to enable it as a system-wide command.

console
Copy
$ sudo ln -s /opt/sonarscanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
Explain Code
View the installed SonarScanner version.

console
Copy
$ sonar-scanner -v
Explain Code
Your output should be similar to the one below.

........
13:33:31.946 INFO  SonarScanner CLI 7.0.1.4817
13:33:31.950 INFO  Java 17.0.13 Eclipse Adoptium (64-bit)
13:33:31.951 INFO  Linux 6.8.0-51-generic amd64
Configure SonarQube
SonarQube requires specific configurations for optimal performance, including database connections, Java runtime options, system resource limits, and user permissions. Follow the steps below to configure SonarQube to run on your server.

Open the main sonar.properties Sonarqube configuration file.

console
Copy
$ sudo nano /opt/sonarqube/conf/sonar.properties
Explain Code
Add the following configurations at the end of the file. Replace sonaruser and your_password with actual PostgreSQL database user details.

ini
Copy
sonar.jdbc.username=sonaruser
sonar.jdbc.password=your_password
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
sonar.web.javaAdditionalOpts=-server
sonar.web.host=0.0.0.0
sonar.web.port=9000
Explain Code
Save and close the file.

The above custom configuration directives enable SonarQube to access the PostgreSQL database, and listen for connections on the TCP port 9000 from all network addresses 0.0.0.0.

Open the sysctl.config configuration file to modify the system memory limits.

console
Copy
$ sudo nano /etc/sysctl.conf
Explain Code
Add the following directives at the end of the file.

ini
Copy
vm.max_map_count=524288
fs.file-max=131072
Explain Code
Save and close the file.

Within the above configuration:

vm.max_map_count=524288: Increases the number of memory maps Elasticsearch can use, allowing it to handle large datasets.
fs.file-max=131072: Increases the maximum number of files Elasticsearch can open, allowing it to run efficiently.
SonarQube uses Elasticsearch to store indices in a memory-mapped file system. Adjusting the system limits for virtual memory mapping and file handling ensures better stability and performance for SonarQube.

Create a new /etc/security/limits.d/99-sonarqube.conf file to create a resource limits configuration for SonarQube.

console
Copy
$ sudo nano /etc/security/limits.d/99-sonarqube.conf
Explain Code
Add the following directives to increase the file descriptor and process limits for SonarQube.

ini
Copy
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
Explain Code
Save and close the file.

Within the configuration:

nofile=131072: Increases the number of open file descriptors, allowing SonarQube to handle large workloads.
nproc=8192: Raises the process limit to prevent failures under high concurrency.
Allow network connections to the SonarQube port 9000.

console
Copy
$ sudo ufw allow 9000/tcp
Explain Code
Run the following command to install UFW and allow SSH connections if it's unavailable.
console
Copy
$ sudo apt install ufw -y && sudo ufw allow 22/tcp
Explain Code
Reload UFW to apply the firewall configurations.

console
Copy
$ sudo ufw reload
Explain Code
View the UFW status and verify that below are the only active firewall rules.

console
Copy
$ sudo ufw status
Explain Code
Your output should be similar to the one below:

Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
9000/tcp                   ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
9000/tcp (v6)              ALLOW       Anywhere (v6)
Set Up SonarQube as a System Service
Follow the steps below to set up a new system service for SonarQube to manage the application processes on your server.

Create a new sonarqube.service file.

console
Copy
$ sudo nano /etc/systemd/system/sonarqube.service
Explain Code
Add the following configurations to the file.

ini
Copy
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
Restart=always

StandardOutput=syslog
LimitNOFILE=131072
LimitNPROC=8192
TimeoutStartSec=5
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
Explain Code
Save and close the file.

The above configuration creates a new SonarQube system service to monitor and manage the application processes.

Reload systemd to apply the service changes.

console
Copy
$ sudo systemctl daemon-reload
Explain Code
Enable SonarQube to start at boot.

console
Copy
$ sudo systemctl enable sonarqube
Explain Code
Start the SonarQube service.

console
Copy
$ sudo systemctl start sonarqube
Explain Code
View the SonarQube service status and verify that it's running.

console
Copy
$ sudo systemctl status sonarqube
Explain Code
Your output should be similar to the one below:

● sonarqube.service - SonarQube service
     Loaded: loaded (/etc/systemd/system/sonarqube.service; enabled; preset: enabled)
     Active: active (running) since Thu 2024-12-26 14:12:47 WAT; 2h 54min ago
    Process: 1085 ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start (code=exited, status=0/SUCCESS)
   Main PID: 1108 (java)
Restart the server to apply the SonarQube installation changes.

console
Copy
$ sudo reboot now
Explain Code
Access SonarQube
SonarQube includes a graphical web-based interface for managing code quality, projects, issues, and security. Follow the steps below to access the SonarQube web interface, update the default administrator password and create a dedicated user for code scanning.

Access the SonarQube port 9000 using your server IP or domain name.

Log in to SonarQube with the following credentials when prompted.

Username: admin
Password: admin
Sonar-Qube-login.png

Change the default administrator password when prompted.
Click Administration within the SonarQube interface, select Security from the list of options, and click the Users dropdown option.

create-user.png

Click Create User to add a new user for code scanning.

sonar-user.png

Click the options symbol in the Tokens column within the new user's row to generate a token.

Enter the token name, select its expiry period, and click Generate.

sonar-user-token.png

Copy the generated token in your output to use it with code scanning.

Scan SonarQube Example Projects
Follow the steps below to test the default SonarQube scanner using an example project.

Switch to your user's home directory.

console
Copy
$ cd
Explain Code
Create a new sample sonar-example-test project directory.

console
Copy
$ mkdir sonar-example-test
Explain Code
Switch to the sonar-example-test directory.

console
Copy
$ cd sonar-example-test
Explain Code
Download the SonarQube example project archive.

console
Copy
$ wget https://github.com/SonarSource/sonar-scanning-examples/archive/master.zip
Explain Code
Extract files from the downloaded archive.

console
Copy
$ unzip master.zip
Explain Code
Switch to the examples directory.

console
Copy
$ cd sonar-scanning-examples-master
Explain Code
Switch to the example sonar-scanner directory.

console
Copy
$ cd sonar-scanner
Explain Code
Scan the code in the entire directory using SonarScanner. Replace user-sonar_token with the user token you generated earlier.

console
Copy
$ sonar-scanner -D sonar.token=user-sonar_token
Explain Code
Your output should be similar to the one below:

INFO  Analysis total time: 22.116 s
INFO  SonarScanner Engine completed successfully
INFO  EXECUTION SUCCESS
INFO  Total time: 26.095s
Visit the SonarQube dashboard to view the scan results and the entire project report.

scan-result.png

Scan Multiple Projects
Follow the steps below to set up your custom code projects to scan using SonarQube on your workstation.

Navigate to your existing project's root directory. For example, myproject.

console
Copy
$ cd myproject
Explain Code
Create a new sonar-project.properties configuration.

console
Copy
$ nano sonar-project.properties
Explain Code
Add the following configurations to the file to define your project settings. Replace the example values with your actual project values.

ini
Copy
# Unique identifier for the project
sonar.projectKey=MyProject:Key1   

# Display name in SonarQube UI  
sonar.projectName=First Project  

# Version number being analyzed
sonar.projectVersion=1.0      

# Brief description of the project
sonar.projectDescription=My First Project   

# Code directory to analyze
sonar.sources=src
Explain Code
Save and close the file.

The above project configuration specifies your project settings and a target directory with the code to scan.

Run the SonarScanner CLI to scan the code in your project and access its report in the SonarQube web dashboard.

console
Copy
$ sonar-scanner -D sonar.token=<sonar_token>
