The ***Spring Framework*** is a powerful, lightweight, and widely used Java framework for building enterprise applications. It provides a comprehensive programming and configuration model for Java-based applications, making development faster, scalable, and maintainable.

Before Enterprise Java Beans (EJB), JavaBeans were used for developing Web applications, but they lacked essential services like transaction management and security. EJB was introduced to address this by offering services for enterprise application development. However, it was complex, requiring developers to create Home and Remote interfaces and implement lifecycle methods.

Spring Framework emerged as a solution to these complications. It simplifies enterprise application development by using techniques like Aspect-Oriented Programming (AOP), Plain Old Java Objects (POJO), and Dependency Injection (DI). Spring is an open-source, lightweight framework that enables Java EE developers to build scalable and reliable applications, offering simpler alternatives to traditional Java APIs like JDBC, JSP, and Servlets.

## What is Spring Framework?

The Spring Framework simplifies Java development and promotes good design practices, offering a comprehensive infrastructure for developing Java applications. It provides tools for creating both small-scale applications and large enterprise systems. Spring is not just a framework for building web applications but also an entire ecosystem that includes components for dependency injection, transaction management, AOP (Aspect-Oriented Programming), and much more. Its modularity means that developers can choose what parts of the framework to use based on project needs.

### Benefits of Using Spring Framework

- ****Simplified Development:**** Spring reduces boilerplate code with features like Dependency Injection and AOP, making development faster and easier.
- ****Loose Coupling:**** Dependency Injection ensures components are loosely coupled, improving maintainability and testability.
- ****Modular:**** Spring's modular architecture allows developers to use only the required components, improving flexibility and efficiency.
- ****Integration Support:**** Spring provides built-in support for various technologies like JDBC, JMS, and JPA, making integration with other systems seamless.
- ****Scalability:**** Spring's lightweight nature and support for various web and enterprise components make it highly scalable for large applications.

### Key Features of Spring Framework

![Key-features-of-Spring-Framework_](https://media.geeksforgeeks.org/wp-content/uploads/20250303123534694297/Key-features-of-Spring-Framework_.webp)

  

The key features of Spring Framework are listed below:

- ****Dependency Injection:**** Dependency Injection is a design pattern where the Spring container automatically provides the required dependencies to a class, instead of the class creating them itself. This promotes loose coupling, easier testing, and better maintainability by decoupling the object creation and usage.
- ****Aspect-Oriented Programming (AOP):**** AOP allows developers to separate cross-cutting concerns (such as logging, security, and transaction management) from the business logic.
- ****Transaction Management:**** Spring provides a consistent abstraction for managing transactions across various databases and message services.
- ****Spring MVC:**** It is a powerful framework for building web applications that follow the Model-View-Controller pattern.
- ****Spring Security:**** Spring provides security features like authentication, authorization, and more.
- ****Spring Data:**** Spring Data is a part of the Spring Framework that simplifies database access by providing easy-to-use abstractions for working with relational and non-relational databases.
- ****Spring Batch:**** Spring Batch is a framework in Spring for handling large-scale batch processing, such as reading, processing, and writing data in bulk.
- ****Integration with Other Frameworks:**** Spring integrates seamlessly with other technologies like Hibernate, JPA, JMS, and more, making it versatile for various enterprise applications.

## Core Concepts of Spring Framework

### 1. Dependency Injection

Dependency Injection is a design pattern used in software development to implement Inversion of Control. It allows a class to receive its dependencies from an external source rather than creating them within the class. This reduces the dependency between classes and makes the system more maintainable.

****Types of Dependency Injection****

****Constructor Injection:**** In constructor injection, the dependent object is provided to the class via its constructor. The dependencies are passed when an instance of the class is created.

****Example:**** This example demonstrates, the Car class depends on the Engine class, and the dependency is provided via the constructor.

> // Constructor Injection
> 
> public class Car {
> 
> private Engine engine;
> 
> public Car(Engine engine) {
> 
> this.engine = engine;
> 
> }
> 
> }

  

****Setter Injection:**** In setter injection, the dependent object is provided to the class via a setter method after the class is instantiated. This allows you to change the dependencies dynamically.

****Example:**** This example, demonstrates the Car class receives the Engine class through a setter method, which is called after the Car object is created.

> // Setter Injection
> 
> public class Car {
> 
> private Engine engine;
> 
> public void setEngine(Engine engine) {
> 
> this.engine = engine;
> 
> }
> 
> }

  

****Field Injection****: In field injection, the dependent object is directly injected into the class through its fields. It is done using framework like Spring(via annotations). The Dependency Injection automatically injects the dependency without requiring explicit constructor or setter methods.

****Example:**** This example, demonstrates the Engine class is injected directly into the Car class through its field, using annotations or DI frameworks.\

> // Field Injection
> 
> public class Car {
> 
> @Autowired
> 
> private Engine engine;
> 
> }

### 2. Inversion of Control (IOC) Container

Inversion of Control (IoC) is a design principle used in object-oriented programming where the control of object creation and dependency management is transferred from the application code to an external framework or container. This reduces the complexity of managing dependencies manually and allows for more modular and flexible code.

In Spring framework there are mainly two types of IOC Container which are listed below:

****BeanFactory****: BeanFactory is the simplest container and is used to create and manage beans. It is a basic container that initializes beans lazily (i.e., only when they are needed). It is typically used for lightweight applications where the overhead of ApplicationContext is not required.

****Example:****

> <bean id="car" class="com.example.Car"/>

****Note:**** This will create a Car bean inside the IoC container, which will be initialized when requested.

  

****Application Context:**** ApplicationContext is an advanced container that extends BeanFactory and provides additional features like internationalization support, event propagation, and AOP (Aspect-Oriented Programming) support. The ApplicationContext is preferred in most Spring applications because of its enhanced features.

****Example:****

> <context:component-scan base-package="com.example"/>

****Note:**** This will scan the specified package for annotated components beans like ****@Component, @Service, @Repository,**** etc.

### 3. Spring Annotation

- ****@Component:**** Marks a class as a Spring bean, allowing Spring to automatically detect and manage it during classpath scanning.
- ****@Autowired:**** Automatically injects dependencies into a class. It can be used on fields, constructors, or methods, allowing Spring to resolve and inject the required beans.
- ****@Bean:**** Defines a Spring bean explicitly within a configuration class. This is used to create and configure beans that are not automatically detected by classpath scanning.
- ****@Configuration:**** Indicates that a class contains bean definitions and acts as a source of bean configuration. It is used to mark a class as a configuration class that contains methods annotated with @Bean to define beans.

These annotations are key for managing the Spring IoC (Inversion of Control) container and defining dependencies in our application.

## Evolution of Spring Framework

The framework was first released under the Apache 2.0 license in June 2003. After that there has been a significant major revision, such as Spring 2.0 provided XML namespaces and AspectJ support, Spring 2.5 provide annotation-driven configuration, Spring 3.0 provided a Java-based @Configuration model. The latest release of the spring framework is 4.0. it is released with the support for Java 8 and Java EE 7 technologies. Though you can still use Spring with an older version of java, the minimum requirement is restricted to Java SE 6. Spring 4.0 also supports Java EE 7 technologies, such as java message service (JMS) 2.0, java persistence API (JPA) 2.1, Bean validation 1.1, servlet 3.1, and JCache.

## Architecture of Spring Framework

![Spring-Framework_](https://media.geeksforgeeks.org/wp-content/uploads/20250226122317588619/Spring-Framework_.webp)

  
The Spring framework consists of seven modules which are shown in the above Figure. These modules are Spring Core, Spring AOP, Spring Web MVC, Spring DAO, Spring ORM, Spring context, and Spring Web flow. These modules provide different platforms to develop different enterprise applications; for example, you can use Spring Web MVC module for developing MVC-based applications.

## Spring Framework Modules

- ****Spring Core Module:**** The core component providing the IoC container for managing beans and their dependencies. It includes BeanFactory and ApplicationContext for object creation and dependency injection.
- ****Spring AOP Module:**** Implements Aspect-Oriented Programming to handle cross-cutting concerns like transaction management, logging, and monitoring, using aspects defined with the @Aspect annotation.
- ****Spring ORM Module:**** Provides APIs for database interactions using ORM frameworks like JDO, Hibernate, and iBatis. It simplifies transaction management and exception handling with DAO support.
- ****Spring Web MVC Module:**** Implements the MVC architecture to create web applications. It separates model and view components, routing requests through the DispatcherServlet to controllers and views.
- ****Spring Web Flow Module:**** Extends Spring Web MVC to manage user flows in web applications. It defines workflows using XML or Java classes for seamless navigation between pages.
- ****Spring DAO Module:**** Provides data access support through JDBC, Hibernate, or JDO, offering an abstraction layer to simplify database interaction and transaction management.
- ****Spring Application Context Module:**** Builds on the Core module, offering enhanced features like internationalization, validation, event propagation, and resource loading via the `ApplicationContext` interface.

### Spring vs Java EE vs Hibernate

|Features|Spring|Java EE|Hibernate|
|---|---|---|---|
|Types|It is a lightweight, modular framework for enterprise applications.|It is a heavyweight platform providing a comprehensive set of services.|It is a framework focuses on ORM(Object Relational Mapping)|
|Modularity|Highly modular means we can use only the needed components.|It comes with a large predefine set of APIs|It entirely focuses on databse interaction|
|Focus Areas|Focuses on Dependency Injection, AOP, and MVC for scalability.|Primarily focuses on enterprise-level services like messaging and transactions.|Simplifies database operations, mapping objects to tables.|
|Transaction Management|Flexible, supports both declarative and programmatic transactions.|Centralized, relies on JTA for managing transactions.|Manages database transactions, but no broader transaction services.|

## How to Download and Use the Spring Framework

### 1. Use a Build Tool (Recommended)

Modern Java Projects use build tool like Maven and Gradle to manage dependencies. We do not need to manually download and install spring framework files. Instead, we declare the dependencies in our build configuration file _****(pom.xml for maven or build.gradle for Gradle).****_

- ****For Maven:**** Add the following dependency to your pom.xml file.

> <dependency>
> 
> <groupId>org.springframework</groupId>
> 
> <artifactId>spring-context</artifactId>
> 
> <version>6.2.6</version>
> 
> </dependency>

- ****For Gradle****: Add the following dependency to your build.gradle

> implementation 'org.springframework:spring-context:6.2.6

### 2. Use Spring Initializr (Easiest way)

The simplest way to set up a Spring project is by using Spring Initializr.

- Visit [https://start.spring.io/](https://start.spring.io/)
- Configure your project (e.g., Maven/Gradle, Java version, dependencies like Spring Boot, Spring MVC, etc.).
- Click Generate to download a pre-configured project.
- Import the project into your IDE (e.g., IntelliJ IDEA, Eclipse).