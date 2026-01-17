# 📡 Advanced I/O & Redirection

Controlling data streams is what separates scripters from engineers.

![IO Streams Placeholder](./io_redirection_streams.svg)

## 📄 Here Documents (HereDocs)
Pass multi-line strings into commands. Ideal for generating config files or passing SQL queries.

```bash
# Creating a file
cat <<EOF > config.json
{
  "host": "localhost",
  "port": 8080
}
EOF

# Ignoring Indexing (Tab characters)
# Use <<-EOF to strip leading tabs (better for indented code)
    cat <<-EOF
    This line will be unindented.
    EOF
```

---

## 🔁 Process Substitution `<()`
Treat the output of a command as a standard file. This allows you to avoid creating temporary files.

### Syntax
`diff <(command1) <(command2)`

### Use Case
Compare the output of two directories without saving `ls` into text files first.
```bash
diff <(ls ./dir1) <(ls ./dir2)
```

---

## 🗄️ File Descriptors
Bash has 3 standard streams:
0.  Stdin
1.  Stdout
2.  Stderr

You can create custom file descriptors (3-9) for advanced reading/writing.

```bash
# Open file for reading on FD 3
exec 3< input.txt

# Read from FD 3
read -u 3 line
echo "Read: $line"

# Close FD 3
exec 3<&-
```
