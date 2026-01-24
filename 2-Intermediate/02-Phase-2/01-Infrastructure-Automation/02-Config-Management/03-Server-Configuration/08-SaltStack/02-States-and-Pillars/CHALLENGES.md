# 🛠️ SaltStack Challenges

## Challenge 1: Remote Execution
**Objective**: Shell out to all minions.
1.  Use the `salt` command to ping all minions: `salt '*' test.ping`.
2.  Install `vim` on all minions using the `pkg.install` module: `salt '*' pkg.install vim`.
3.  Find the disk usage of all minions: `salt '*' disk.usage`.

## Challenge 2: Pillars (Secrets)
**Objective**: Assign sensitive data.
1.  Define a pillar `users.sls` with a username and password.
2.  In your `top.sls`, assign this pillar to a minion.
3.  Use the `pillar.get` function in a state file to create that user.

## Challenge 3: Beacons and Reactors (Advanced)
**Objective**: Event-driven fix.
1.  Configure a **Beacon** to monitor if the SSH service stops.
2.  Configure a **Reactor** to automatically run `service.start ssh` when the event is detected.
