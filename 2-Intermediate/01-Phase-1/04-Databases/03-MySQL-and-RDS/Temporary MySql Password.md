#### STEP 1 — Check if MySQL is running

Run this:
```bash
sudo systemctl status mysqld
```

If it’s inactive, start it:
```bash
sudo systemctl start mysqld
```

---

#### 🧰 STEP 2 — Get the temporary root password (if setup just happened)

When MySQL is first installed, it generates a **temporary root password** in the log file.

Run this:

`sudo grep 'temporary password' /var/log/mysqld.log`

You’ll see something like:

`2025-10-05T22:14:32.123456Z 6 [Note] A temporary password is generated for root@localhost: Abcd@1234`

Copy that temporary password (e.g. `Abcd@1234`).

---

### 🔑 STEP 3 — Login with that temporary password

`sudo mysql -u root -p`

(Then paste the temporary password when prompted.)

If this works — you’re inside MySQL now.

---

### 🧭 STEP 4 — Change the root password manually

Once logged in, run:

```bash
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Mysql$3773!'; FLUSH PRIVILEGES; EXIT;
```
---

### 🧠 STEP 5 — Verify the new password

Now test:

`mysql -u root -p'mysql$3773' -e "SHOW DATABASES;"`

You should see:

`+--------------------+ | Database           | +--------------------+ | information_schema | | mysql              | | performance_schema | | petclinic          | +--------------------+`

---

### 🚑 IF YOU STILL CAN’T LOGIN

It may be using the `auth_socket` plugin instead of password auth.  
To check and fix that:

1. Log in with **sudo** as MySQL root (bypasses password):
    

`sudo mysql`

2. Then run:
    

`ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mysql$3773'; FLUSH PRIVILEGES; EXIT;`

Now test again:

`mysql -u root -p'mysql$3773'`

✅ This should work.

---

Would you like me to modify your Jenkins pipeline so it **forces MySQL to use `mysql_native_password` authentication** (so this problem never happens again)?