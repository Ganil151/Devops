1. Install OpenJDK 21:

- **Update System:** Ensure your system's package index is up-to-date:
```bash
sudo dnf update -y
```
- **Install OpenJDK 21:** Install the OpenJDK 21 development package (includes JRE and compiler
```bash
sudo dnf install java-21-openjdk-devel -y
```

2. Configure Alternatives (if multiple Java versions are installed):

- **Check Java Alternatives:** View available Java versions and their priorities:

Code

```
    sudo update-alternatives --config java
```

- **Select JDK 21:** If multiple versions are listed, choose the number corresponding to the OpenJDK 21 entry to set it as the default.

3. Set JAVA_HOME Environment Variable (Optional but Recommended):

- **Determine JAVA_HOME path:** Find the installation path of OpenJDK 21. It's typically `/usr/lib/jvm/java-21-openjdk-<version>`. You can find the exact path by running:

Code

```
    readlink -f $(which java)
```

- **Set JAVA_HOME:** Add the `JAVA_HOME` variable to your system's profile for persistent configuration. For example, add the following to `/etc/profile.d/java.sh` (create if it doesn't exist):

Code

```
    echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk' | sudo tee -a /etc/profile.d/java.sh    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/java.sh
```

Note: Replace `/usr/lib/jvm/java-21-openjdk` with the actual path if different.

- **Apply Changes:** Source the profile to apply the changes in the current session:

Code

```
    source /etc/profile.d/java.sh
```

4. Verify Installation:

- **Check Java Version:** Confirm that JDK 21 is now the default:

Code

```
    java -version
```

The output should display "openjdk version "21.x.x"".

- **Check Javac Version:** Verify the compiler version:

Code

```
    javac -version
```

The output should display "javac 21.x.x".