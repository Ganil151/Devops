Pull Java 
```bash
[root@master-server ~]# which java
/usr/bin/java
[root@master-server ~]# readlink -f $(which java)
/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java
```

Copy SSH Key from master to worker
```bash
ssh-copy-id <user-name@public-ip>
```

Plugins

Credentials
![alt text](<Screenshot (195).png>)