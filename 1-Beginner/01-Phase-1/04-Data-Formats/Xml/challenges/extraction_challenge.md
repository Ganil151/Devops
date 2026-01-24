# 🛠️ XML Challenge: Data Extraction from POM

**Scenario**: You are automating a security audit. Your script needs to find out exactly which version of a library is being used in 500 different Java projects.

**Task**: Extract the `artifactId` and `version` from the provided Maven `pom.xml` snippet.

## Target Snippet: `project_pom.xml`
```xml
<project>
    <groupId>org.example</groupId>
    <artifactId>security-middleware</artifactId>
    <version>2.4.11-BETA</version>
</project>
```

## Requirements:
1. **Tooling**: You may use `xmllint`, `xmlstarlet`, or a simple **Python** script using `xml.etree.ElementTree`.
2. **Precision**: Your output must be plain text in the format: `Artifact: [name], Version: [version]`.

## Deliverable:
Save your solution script (Bash or Python) as `pom_extractor.sh` or `pom_extractor.py` in the `solutions/` folder.
