**Dynamic application security testing** (**DAST**) represents a non-functional testing process to identify security weaknesses and vulnerabilities in an application. This testing process can be carried out either manually or by using automated tools. Manual assessment of an application involves human intervention to identify the security flaws which might slip from an automated tool. Usually business logic errors, race condition checks, and certain zero-day vulnerabilities can only be identified using manual assessments.

On the other side, a DAST tool is a program which communicates with a web application through the web front-end in order to identify potential security vulnerabilities in the web application and architectural weaknesses. It performs a black-box test. Unlike <font color="#ffc000">static application security testing</font> ([[SAST TEST]]) tools, DAST tools do not have access to the source code and therefore detect vulnerabilities by actually performing attacks.

DAST tools allow sophisticated scans, detecting vulnerabilities with minimal user interactions once configured with host name, crawling parameters and authentication credentials. These tools will attempt to detect vulnerabilities in query strings, headers, fragments, verbs (GET/POST/PUT) and DOM injection.

DAST tools facilitate the automated review of a web application with the express purpose of discovering security vulnerabilities and are required to comply with various regulatory requirements. Web application scanners can look for a wide variety of vulnerabilities, such as input/output validation: (e.g. [[cross-site scripting]] and [[SQL injection]], specific application problems and server configuration mistakes.
### Strengths
These tools can detect vulnerabilities of the finalized release candidate versions prior to shipping. Scanners simulate a malicious user by attacking and probing, identifying results which are not part of the expected result set, allowing for a realistic attack simulation. The big advantage of these types of tools are that they can scan year-round to be constantly searching for vulnerabilities. With new vulnerabilities being discovered regularly this allows companies to find and patch vulnerabilities before they can become exploited.[

As a dynamic testing tool, web scanners are not language-dependent. A web application scanner is able to scan engine-driven web applications. Attackers use the same tools, so if the tools can find a vulnerability, so can attackers.
### Weaknesses
While scanning with a DAST tool, data may be overwritten or malicious payloads injected into the subject site. Sites should be scanned in a production-like but non-production environment to ensure accurate results while protecting the data in the production environment.

Because the tool is implementing a dynamic testing method, it cannot cover 100% of the source code of the application and then, the application itself. The penetration tester should look at the coverage of the web application or of its attack surface to know if the tool was configured correctly or was able to understand the web application.

The tool cannot implement all variants of attacks for a given vulnerability. So the tools generally have a predefined list of attacks and do not generate the attack payloads depending on the tested web application. Some tools are also quite limited in their understanding of the behavior of applications with dynamic content.

### DAST Tools
- **OWASP ZAP (Zed Attack Proxy):** Free, open-source tool for finding web application vulnerabilities.
  - [OWASP ZAP Website](https://www.zaproxy.org/)
- **Burp Suite:** Popular commercial and community tool for web vulnerability scanning and penetration testing.
  - [Burp Suite Website](https://portswigger.net/burp)
- **Acunetix:** Automated web vulnerability scanner for complex web applications.
  - [Acunetix Website](https://www.acunetix.com/)
- **Nikto:** Open-source web server scanner for detecting dangerous files, outdated software, and server misconfigurations.
  - [Nikto Website](https://cirt.net/Nikto2)
- **AppScan:** IBM's enterprise-grade DAST solution.
  - [AppScan Website](https://www.ibm.com/products/appscan)
- **Netsparker:** Automated, commercial web application security scanner.
  - [Netsparker Website](https://www.invicti.com/)
#### VS Code Extensions for DAST
While DAST tools are typically run externally, some extensions and integrations can help manage or trigger DAST scans from within VS Code:
- **OWASP ZAP Integration:**  
  [ZAP API Extension](https://marketplace.visualstudio.com/items?itemName=infosec-intern.vscode-zap) – Integrates ZAP with VS Code for launching scans and viewing results.
- **REST Client:**  
  [REST Client Extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) – Useful for manual API testing and simulating attacks.
- **Thunder Client:**  
  [Thunder Client Extension](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client) – Lightweight REST API client for testing endpoints, useful for manual DAST-like testing.

