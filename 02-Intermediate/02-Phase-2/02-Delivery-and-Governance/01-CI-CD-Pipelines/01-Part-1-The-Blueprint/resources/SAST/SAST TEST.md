## Static Application Security Testing

### What is Static Application Security Testing (SAST)?
SAST stands for static application security testing, a type of software testing methodology that analyzes source code or compiled versions of applications to identify injection flaws, cross-site scripting (XSS), insecure data handling and other pervasive security weaknesses outlined in the OWASP Top 10 and SANS Top 25. 

Considered a white-box testing technique, SAST operates without executing the application. Instead, it relies on static code analysis techniques, such as data flow analysis, control flow analysis and syntactic pattern matching. 

SAST tools typically integrate with integrated development environments (IDEs), version control systems, and `continuous integration/continuous deployment (CI/CD) pipelines` to provide early and continuous feedback on potential security issues. This enables developers to remediate vulnerabilities before they become part of the compiled or packaged application. 

By using sophisticated code analysis techniques, SAST tools can effectively and efficiently assess large codebases, identify potential security vulnerabilities and provide developers with actionable insights to improve the security posture of their applications..

### How SAST Works
At its core, SAST examines an application's source code, bytecode or binary code in search of security weaknesses. SAST can identify a variety of vulnerabilities, including SQL injections, buffer overflows and XSS. By flagging these potential threats early in the SDLC (<font color="#ffc000">Software Development Life Cycle</font>), static application security testing helps developers remediate issues to enhance the security of the application — before deployment.

<font color="#ffc000">SAST works by scanning an application's source code to identify coding patterns that could lead to potential vulnerabilities</font>. It systematically checks the code against a set of predefined rules or conditions that pertain to secure coding practices. On detection of a potential weakness, it flags the area in the code where it found the issue, giving developers the opportunity to remedy it before deployment. 

Steps in the SAST process include:
**Step 1: Code Parsing**
SAST tools begin by parsing the source code, byte code or binary code to create an <font color="#ffc000">Abstract Syntax Tree</font> (AST). The AST represents the code's structure and its various components, such as functions, loops, conditional statements and variables.

**Step 2: Control and Data Flow Analysis**
The SAST tool performs control flow analysis and data flow analysis to understand the application's behavior. Control flow analysis identifies the execution paths through the code, while data flow analysis tracks how data moves between variables, functions and other code components. This helps in identifying insecure data handling, such as SQL injections or XSS vulnerabilities.

**Step 3: Security Rules and Policies**
SAST tools contain a set of predefined security rules and policies that are used to analyze the code for potential vulnerabilities. These rules are based on industry standards, known vulnerabilities and security standards like [[OWASP]] Top Ten or [[CWE SANS]] Top 25.

**Step 4: Pattern Matching and Semantic Analysis**
The SAST tool applies pattern matching and semantic analysis techniques to identify code components that match the predefined security rules and policies. This process helps detect insecure coding practices, such as weak encryption algorithms, hard-coded passwords or the use of vulnerable libraries.

### The SAST Cycle
Static application security testing can be considered an ongoing cyclical process, particularly when integrated into the SDLC as part of a<font color="#ffc000"> continuous integration and continuous deployment</font> (CI/CD) pipeline. By incorporating SAST in development, DevOps teams can proactively identify and remediate security vulnerabilities throughout the build process.
- **Code Development**: Developers write and commit source code, implementing new features or fixing bugs in the application.
- **Integration with CI/CD**: When code is committed to the version control system (e.g., Git), the CI/CD pipeline is triggered, which automates the build, testing and deployment process.
- **SAST Execution**: As part of the pipeline, and based on predefined rules and policies, SAST tools analyze the source code, byte code or binary code for potential security vulnerabilities.
- **Vulnerability Reporting**: The SAST tool generates a report with detailed information about detected vulnerabilities, their severity and suggested remediation steps.
- **Remediation**: Developers review the report and address identified vulnerabilities, making necessary changes to the source code to eliminate the issues.
- **Retesting**: The updated code is committed to the version control system, and the CI/CD pipeline is triggered again, repeating the cycle of SAST analysis, reporting and remediation.

This cyclical process helps to identify and resolve security vulnerabilities throughout development. By integrating SAST as part of a continuous testing strategy, organizations maintain a high level of security and minimize the cost and effort associated with fixing vulnerabilities at later stages of development.
### Why SAST is Important in DevSecOps
In an age where data breaches can significantly impact an organization's reputation and bottom line, early detection and remediation of vulnerabilities are essential. By detecting code-level vulnerabilities such as buffer overflows, injection flaws and insecure library calls, SAST plays a critical role in enhancing the security posture of an application.
- **Shift Left Security:** SAST enables security to be addressed early in the SDLC, reducing the cost and effort of fixing vulnerabilities.
- **Continuous Security:** Integrating SAST into DevSecOps workflows ensures that every code change is automatically checked for security issues.
- **Compliance:** Many regulations and standards (e.g., PCI DSS, OWASP) require secure coding practices and regular code reviews.
- **Developer Empowerment:** Developers receive immediate feedback on security issues, enabling them to learn and improve code quality.
- **Reduced Risk:** Early detection and remediation of vulnerabilities help prevent security breaches and protect sensitive data.

### Role of SAST in DevSecOps
With its focus on detecting vulnerabilities early in the SDLC, static application security testing aligns well with the `DevSecOps` ethos of shifting left. By identifying potential security issues in the codebase, SAST  encourages the development of secure code and contributes to robust application security. SAST also helps maintain the speed of `DevOps` practices without compromising security, reinforcing its contribution to an effective DevSecOps program.
### SAST and Compliance
SAST not only improves code quality but also aids in meeting various compliance requirements. Regulations such as the <font color="#ffc000">Payment Card Industry Data Security Standard</font> (PCI DSS) and the <font color="#ffc000">General Data Protection Regulation </font>(GDPR) mandate preemptive measures to ensure data security. These mandate measures include identifying and addressing software vulnerabilities.

Running SAST as part of the SDLC demonstrates due diligence in these respects. It can provide reports needed for compliance audits, illustrating an organization’s commitment to securing software against potential breaches.

### SAST Vs. DAST
In contrast to SAST as a white-box method of application security testing, dynamic application security testing ([[DAST]]) is a black-box testing technique that examines an application in a simulated runtime state to find vulnerabilities an attacker could exploit.

To differentiate these testing methods, think of SAST as the insider or developer's approach and DAST as the outsider or hacker’s approach. With SAST, the developer has full knowledge of the application’s internal structure, logic and implementation details. With DAST, the tester has no knowledge of what’s inside the black box.

### SAST and DAST At-a-Glance

**Testing Approach:**
- SAST: Analyzes source code, byte code or binary code without executing the application, focusing on its internal structure and logic.
- DAST: Tests the application while it's running, simulating actual attacks to identify security vulnerabilities in a live environment.

**Visibility:**
- SAST: White-box testing, from the inside out, with full access to the source code or compiled code, which enables a deeper understanding of the application's internal workings.
- DAST: Black-box testing, from the outside in, treating the application as a black box with no knowledge of its internal implementation, focusing on its exposed interfaces and behavior.

**Vulnerability Detection:**
- SAST: Identifies potential vulnerabilities by analyzing code for insecure coding practices, weak algorithms] or the use of vulnerable libraries.
- DAST: Discovers vulnerabilities by probing the application's exposed interfaces, such as webpages or APIs, for weaknesses attackers can exploit.

**Integration with SDLC:**
- SAST: Can be integrated early in the software development lifecycle, enabling developers to identify and fix vulnerabilities before deploying the application.
- DAST: Typically performed during late stages of the SDLC, often after deploying the application to a testing or staging environment.

**Speed and Scalability:**
- SAST: Can be time-consuming, especially for large codebases, as it needs to thoroughly analyze the entire codebase.
- DAST: Can be faster, as it tests the running application and focuses on specific exposed interfaces, but may require more resources to simulate valid attack scenarios.

**Accuracy:**
- SAST: May produce false positives or false negatives due to the static nature of the analysis, which may not always consider the full context of runtime behavior.
- DAST: Tends to have fewer false positives, as it tests the application in a running state within close-to-authentic conditions.

**Types of Vulnerabilities Detected:**
- SAST: Effective at detecting issues like <font color="#ffc000">SQL injections</font>, <font color="#ffc000">buffer overflows</font>, <font color="#ffc000">cross-site scripting</font>, and insecure use of cryptography.
- DAST: Better at identifying vulnerabilities like server misconfigurations, security issues in third-party components and runtime vulnerabilities not visible in the source code.

SAST and DAST offer complementary approaches to application security testing, each with strengths and weaknesses. Using them together as part of a comprehensive security testing strategy allows organizations to catch and remediate issues during development — and to identify issues that surface only when the application is running.

#### Example SAST Findings
- Hardcoded credentials in source code
- SQL injection vulnerabilities
- Cross-site scripting (XSS) flaws
- Use of insecure cryptographic algorithms
- Missing input validation
### SAST Tools
- **SonarQube:** An open-source platform for continuous inspection of code quality and security.
- **Checkmarx:** A commercial SAST tool supporting multiple languages and frameworks.
- **Fortify Static Code Analyzer:** A comprehensive enterprise-grade SAST solution.
- **Bandit:** A Python-specific static analysis tool for finding security issues.
- **Brakeman:** A static analysis tool for Ruby on Rails applications.
#### VS Code Extensions for SAST Tools
 Visual Studio Code extensions that integrate SAST tools or provide static code analysis for security:
- **SonarLint:** Provides real-time feedback and code analysis for security and quality issues.  
  [SonarLint Extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarlint-vscode)
- **Bandit Security Linter:** Python security linter that can be run from the terminal or integrated with tasks.  
  [Bandit Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python) (Bandit runs via Python extension tasks)
- **ESLint:** While primarily for code quality, it can catch some security issues in JavaScript/TypeScript.  
  [ESLint Extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- **Checkov:** Scans Infrastructure as Code (IaC) for security issues, useful for DevSecOps pipelines.  
  [Checkov Extension](https://marketplace.visualstudio.com/items?itemName=bridgecrew.checkov)
- **Semgrep:** Fast, open-source static analysis for finding security bugs and enforcing code standards.  
  [Semgrep Extension](https://marketplace.visualstudio.com/items?itemName=returntocorp.semgrep)
- **Security Code Scan:** Security static analysis for C# and VB.NET projects.  
  [Security Code Scan Extension](https://marketplace.visualstudio.com/items?itemName=SecCoScan.SecurityCodeScanVSExtension)

---

Static Application Security Testing is a foundational practice in DevSecOps, helping teams build secure software from the start and maintain a strong security posture throughout the development lifecycle.


https://youtu.be/gLJdrXPn0ns?t=641
