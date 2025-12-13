
```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-project -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

To create a new Maven project in VS Code using the integrated terminal, follow these steps:
- **Open VS Code and navigate to your desired project directory:**
	- Open Visual Studio Code.
	- Open the folder where you want to create your Maven project (File > Open Folder...).
- **Open the integrated terminal:**
    - Go to `View > Terminal` or use the shortcut `Ctrl+` (backtick).
- **Execute the Maven archetype generation command:**
    - In the terminal, run the following command to generate a basic Maven project using the `maven-archetype-quickstart` archetype:
    
- **Explanation of parameters:**
    - `-DgroupId=com.example`: Defines the group ID for your project (e.g., `com.yourcompany`).
    - `-DartifactId=my-project`: Defines the artifact ID for your project (e.g., `my-app`).
    - `-DarchetypeArtifactId=maven-archetype-quickstart`: Specifies the archetype to use for generating the project structure. This creates a simple Java project with a `pom.xml` and a sample `App.java` file.
    - `-DinteractiveMode=false`: Runs the command in non-interactive mode, so it won't prompt you for values during the process.

- **Replace placeholders with your project details:**    
    - Change `com.example` to your desired group ID.
    - Change `my-project` to your desired artifact ID (project name).
    
- **Confirm project creation (if prompted):**    
    - If `DinteractiveMode=false` is omitted, Maven might ask for confirmation (e.g., "Y/N"). Type `Y` and press Enter.
    
- **Open the newly created project in VS Code (optional):**    
    - After the command completes, a new folder with your `artifactId` (e.g., `my-project`) will be created within your chosen directory.
    - You can then open this new project folder in VS Code (`File > Open Folder...` and select the `my-project` folder) to start working on your Maven project.