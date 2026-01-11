# 🔀 Input/Output (Streams & Redirection)

> **"In Unix, everything is a file. Even the output flowing through your pipes."**

![Input Output Banner](../../assets/io_banner.png)

## 📚 Overview

Every process in Linux has three standard streams connecting it to the world. Mastering I/O redirection allows you to save log files, chain commands together ("Piping"), and silence errors. This is the glue that holds the Unix philosophy together.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Understand File Descriptors: 0 (Stdin), 1 (Stdout), 2 (Stderr)
- ✅ Redirect output to files (`>` vs `>>`)
- ✅ Silence errors using `2>/dev/null`
- ✅ Redirect errors to standard output (`2>&1`)
- ✅ Master the Pipe (`|`)

## 🏗️ The Three Streams

```mermaid
graph LR
    Keyboard[⌨️ Keyboard] -->|Stdin (0)| Process[⚙️ COMMAND]
    
    Process -->|Stdout (1)| Screen[🖥️ Screen]
    Process -->|Stderr (2)| Screen
    
    style Process fill:#3498db,color:#fff
    style Screen fill:#2ecc71,color:#fff
    style Keyboard fill:#f1c40f,stroke:#333
```

## 🛠️ Redirection Tools

### 1. Output Redirection (`>`) -> "Save it"
Writes standard output to a file.
**WARNING**: `>` Overwrites! `>>` Appends.

```bash
# Overwrite (Dangerous)
ls > file_list.txt

# Append (Safe)
date >> app.log
```

### 2. Error Redirection (`2>`) -> "Handle problems"
Separately handle error messages.

```bash
# Save output to log, errors to error.log
./script.sh 1> success.log 2> error.log
```

### 3. The "Black Hole" (`/dev/null`)
Discard unwanted output.

```bash
grep "pattern" file.txt 2> /dev/null
```

### 4. The Pipe (`|`) -> "Chain it"
Pass the output of Command A as input to Command B.

```bash
cat access.log | grep "404" | wc -l
```
*(Read log -> Find 404s -> Count them)*

## 🏆 Real-World DevOps Story

### 💡 **The Cron Job Email Spam**

**Scenario**: A SysAdmin wrote a cron job to sync files every minute.
`* * * * * rsync -a source dest`

**The Problem**:
`rsync` works fine, but occasionally prints innocent warnings. Cron captures any output and **emails** it to the user. The admin woke up to 1,400 emails.

**The Fix**:
Silence the output properly.
```bash
* * * * * rsync -a source dest > /dev/null 2>&1
```
`> /dev/null`: Throw away standard output.
`2>&1`: Send errors (2) to the same place as output (1) (which is /dev/null).

**Result**: Peace and quiet.

## 🎓 Interview Questions

### Q1: What does `2>&1` mean?
<details>
<summary>Click to reveal answer</summary>

It redirects **File Descriptor 2 (Stderr)** to the location of **File Descriptor 1 (Stdout)**.
Usually used to merge errors into the standard output stream so they can be piped or saved together.
</details>

### Q2: How do you feed a file into a command as input?
<details>
<summary>Click to reveal answer</summary>

Use the `<` operator.
```bash
mysql -u root -p < database_dump.sql
```
</details>

### Q3: What is the difference between `|` and `|&`?
<details>
<summary>Click to reveal answer</summary>

- `|`: Pipes only Stdout. Logic errors print to screen and don't go to the next command.
- `|&`: Pipes BOTH Stdout and Stderr to the next command (Bash 4.0+ shortcut for `2>&1 |`).
</details>

## 📝 Quiz

1. **Which File Descriptor represents "Standard Output"?**
   - [ ] a) 0
   - [x] b) 1
   - [ ] c) 2
   - [ ] d) 3

2. **Which operator APPENDS to a file?**
   - [ ] a) `>`
   - [x] b) `>>`
   - [ ] c) `<`
   - [ ] d) `|`

3. **Where do you send output to delete it?**
   - [ ] a) `/dev/zero`
   - [ ] b) `/tmp`
   - [x] c) `/dev/null`
   - [ ] d) `/void`

4. **What symbol is the "Pipe"?**
   - [ ] a) `>`
   - [ ] b) `/`
   - [x] c) `|`
   - [ ] d) `&`

5. **`2>` redirects what?**
   - [ ] a) Input
   - [ ] b) Output
   - [x] c) Errors (Stderr)
   - [ ] d) Network traffic

**Answers**: 1-b, 2-b, 3-c, 4-c, 5-c

## 🔗 Next Steps

**🎉 CONGRATULATIONS! You have completed the Beginner Shell Scripting Module!**

👉 Proceed to the **[Labs Directory](../Labs/README.md)** to practice your skills!

## 📚 Additional Resources
- [I/O Redirection Illustrated](https://wiki.bash-hackers.org/syntax/redirection)
- [Explaining Shell Pipelines](https://dev.to/ben/explaining-shell-pipelines-1g6m)

---
**📌 Pro Tip**: `tee` is a T-junction pipe. It saves to a file AND displays to screen.
`echo "Hello" | tee file.txt`
