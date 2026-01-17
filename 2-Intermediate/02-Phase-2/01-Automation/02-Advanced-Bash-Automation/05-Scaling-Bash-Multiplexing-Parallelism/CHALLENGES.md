# 🛠️ Parallelism Challenges

## Challenge 1: Parallel Ping Sweeper

**Objective**: Use `xargs` to speed up a network scan by 5x.

**Step 1: Create a Dummy Hosts File**
```bash
# Generate 20 fake IPs
for i in {1..20}; do echo "192.168.1.$i" >> hosts.txt; done
```

**Step 2: Parallel Scan**
Use `xargs` to run 5 checks at a time.
```bash
time cat hosts.txt | xargs -P 5 -I {} bash -c 'sleep 1; echo "Checked {}"'
```
*Expected Result*: Takes ~4 seconds (20 tasks / 5 parallel threads = 4 rounds).

## Challenge 2: The Image Resizer
Write a script that finds all `.jpg` files in a directory and uses `job control` (`&` and `wait`) to resize them (simulate with `sleep 1`) in bunches of 4.
*Hint*: You might need a counter loop.
