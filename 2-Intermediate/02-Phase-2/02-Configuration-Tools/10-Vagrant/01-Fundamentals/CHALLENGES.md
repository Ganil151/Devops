# 🛠️ Vagrant Challenges

## Challenge 1: Networking Basics
**Objective**: Local Port Forwarding.
1.  Initialize a box: `vagrant init ubuntu/focal64`.
2.  Enable a forwarded port so that `localhost:8000` on your host goes to `80` on the VM.
3.  Install Nginx and verify you can see the "Welcome" page from your host browser.

## Challenge 2: Synced Folders
**Objective**: Share code with the VM.
1.  Create an `html/` folder on your host.
2.  In the `Vagrantfile`, sync `./html` to `/var/www/html` on the guest.
3.  Modify `html/index.html` on your host and observe the change immediately inside the VM.

## Challenge 3: Resource Tuning
**Objective**: Speed up the VM.
1.  Configure the `virtualbox` provider.
2.  Set `v.memory = 2048` and `v.cpus = 2`.
3.  Run `vagrant reload` to apply settings.
