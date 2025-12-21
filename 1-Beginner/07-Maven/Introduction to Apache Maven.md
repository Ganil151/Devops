**Apache Maven*** is a powerful project management and build automation tool used mainly for Java-based projects. Built on the ***Project Object Model (POM)**, it handles tasks like compiling code, managing dependencies, and generating documentation. Compared to older tools like Ant, Maven offers a more advanced, **convention-based approach*** that reduces the need for manual configuration. It streamlines the build process and helps developers better understand and manage complex Java applications.
### Key Terminologies in Maven
1. ***POM Files:*** <font color="#ffc000">Project Object Model(POM)</font> files are XML files that contain information related to the project and configuration information, such as dependencies, source directory, plugins, goals, etc., used by Maven to build the project. When you execute a Maven command, you give Maven a POM file to execute the commands. Maven reads the pom.xml file to accomplish its configuration and operations.
2. ***Dependencies and Repositories:*** <font color="#ffc000">Dependencies are external Java libraries required for a Project, and repositories are directories of packaged JAR files. The local repository is just a directory on your machine's hard drive</font>. If the dependencies are not found in the local Maven repository, Maven downloads them from a central Maven repository and puts them in your local repository.
3. **Build Life Cycles, Phases, and Goals:** A build lifecycle consists of a sequence of build phases, and each build phase includes a sequence of goals. A Maven command typically refers to a build lifecycle, phase, or goal. If a lifecycle is executed using a Maven command, all build phases in that lifecycle are also executed. If a build phase is executed, all preceding phases in the defined sequence are executed as well.
4. **Build Profiles:*** Build profiles are a set of configuration values that allow you to build your project using different configurations. For example, you may want to build your project for local development, testing, or production. To enable these builds, you can define different build profiles in your `pom.xml` using its `profiles` element, which can be triggered in various ways.
5. **Build Plugins:*** Build plugins are used to perform specific goals. You can add plugins to the `pom.xml` file. Maven offers standard plugins, and you can also implement custom plugins in Java.

## ***What is Maven?***
Maven is mainly used to build and manage Java projects, especially large-scale ones. It simplifies packaging, testing, and deploying Java applications. With Maven, developers can manage complex projects more easily using predefined lifecycles and project structures.
## How to install Maven
The installation of Maven includes the following Steps:
1. Verify whether your system has Java installed or not. If not, then install Java (Link for Java Installation )
2. Check Java environmental variable is set or not. if not then set java environmental variable(link to install java and setting environmental variable)
3. Download maven from the official website.
4. Unpack your maven zip at any place in your system.
5. Add the bin directory of the created directory apache-maven-3.5.3(it depends upon your installation version) to the PATH environment variable and system variable.
6. Open cmd and run **mvn -v** command. If Maven prints its version and Java info, installation is successful.

## Maven Architecture
Maven repository is a place where the maven artifacts or dependencies of the JAR file is going to store which are written in the file called the POM.XML. POM.XML contains the Java classes, resources, and other dependencies. There are the two types of repositories like local repository and remote repository.
![[maven-architecture.png]]Maven reads the pom.xml file. Maven downloads the dependencies defined in the pom.xml file into the local repository from the central or remote repository. Maven executes the life cycles, phases, goals, and plugins defined in the pom.xml file.
## Maven Repository
Maven repositories are directories of packaged JAR files along with their metadata. The metadata are POM files related to the projects each packaged JAR file belongs to, including what external dependencies each packaged JAR has. This metadata enables Maven to download dependencies of your dependencies recursively until all dependencies are download and put into your local machine. Maven has three types of repository: Maven searches for dependencies in this repositories. First maven searches in Local repository then Central repository then Remote repository if Remote repository specified in the POM.
![[Maven-Repository.jpg]]****1. Local repository:**** A local repository is a directory on the machine of developer. This repository contains all the dependencies Maven downloads. Maven only needs to download the dependencies once, even if multiple projects depends on them (e.g. ODBC). By default, maven local repository is user_home/m2 directory. example - ****C:\Users\asingh\.m2****

****2. Central repository:**** The central Maven repository is created Maven community. Maven looks in this central repository for any dependencies needed but not found in your local repository. Maven then downloads these dependencies into your local repository.

****3. Remote repository:**** Remote repository is a repository on a web server from which Maven can download dependencies.it often used for hosting projects internal to the organization. Maven then downloads these dependencies into your local repository.

- Maven can add all the dependencies required for the project automatically by reading pom file.
- One can easily build their project to jar, war etc. as per their requirements using Maven.
- Maven makes easy to start project in different environments and one doesn't needs to handle the dependencies injection, builds, processing, etc.
- Adding a new dependency is very easy. One has to just write the dependency code in pom file.
- Maven needs the maven installation in the system for working and maven plugin for the ide.
- If the maven code for an existing dependency is not available, then one cannot add that dependency using maven.
- When there are a lot of dependencies for the project. Then it is easy to handle those dependencies using maven.
- When dependency version update frequently. Then one has to only update version ID in pom file to update dependencies.
- Continuous builds, integration, and testing can be easily handled by using maven.
- When one needs an easy way to Generating documentation from the source code, Compiling source code, Packaging compiled code into JAR files or ZIP files.

To know more about Maven Repository refer to this article [Maven Repositories](https://www.geeksforgeeks.org/advance-java/maven-repositories-1/)

## Why we use Maven?

Maven can be used for the following:

### ****1. Easy Project Build****

Maven makes it simple to build projects automatically. You don't need to manually handle the process of compiling code, running tests, or creating project packages. Maven takes care of these tasks for you.

### ****2. Managing Dependencies****

With Maven, adding external libraries (JARs) and other dependencies to your project is easy. Instead of manually downloading and linking them, Maven automatically handles and downloads required libraries for your project.

### ****3. Project Information Generation****

Maven provides useful project reports, including:

- ****Log documents****: Tracks the build process.
- ****Dependency lists****: Shows all libraries your project relies on.
- ****Test reports****: Provides results from unit tests.  
    These reports help you track your project's progress and health.

### ****4. Updating Repositories****

Maven is helpful when you need to update the central repository with new or updated JARs and dependencies. It automatically ensures that your local project is synced with the most recent versions from the repository.

### ****5. Build Output Types****

With Maven, you can easily convert your project into different output formats, such as JAR, WAR, and other types. It automates this process without needing any manual scripting.

### ****6. Integration with Source Control Systems****

Maven easily integrates with source control systems like Git and Subversion. This allows you to keep track of changes to your project’s codebase and collaborate with other developers.

### ****7. Managing the Build Lifecycle****

Maven helps manage the project’s build lifecycle, which includes tasks like:

- ****Compiling****: Converting source code to executable code.
- ****Testing****: Running unit tests to check for errors.
- ****Packaging****: Creating the final product (e.g., a JAR or WAR file).
- ****Deploying****: Uploading the project to a remote server or repository.

### ****8. Standard Project Structure****

Maven enforces a standard project structure, making it easier for developers to understand how a project is organized. This means anyone familiar with Maven can easily locate the necessary files and folders in the project.

### ****9. Support for Multi-Module Projects****

Maven allows you to work with multi-module projects. These are projects that consist of multiple smaller sub-projects. Maven makes it easy to manage the dependencies and build process for these related projects.

### ****10. Plugin Support for Extra Functionality****

Maven has plugins that can add extra features to your build process. For example, you can use plugins for:

- ****Code coverage analysis****: Measures how much of your code is tested.
- ****Static code analysis****: Reviews code for errors and coding standards.

### ****11. High Customizability****

Maven is highly customizable, meaning developers can tailor the build process to fit their specific needs. Whether it's adding specific plugins, modifying configuration settings, or changing build steps, Maven allows flexibility.

### ****12. Simplified Dependency Management****

Maven simplifies dependency management, ensuring that the right versions of libraries are always used in the project. This helps avoid conflicts when using different versions of the same library.