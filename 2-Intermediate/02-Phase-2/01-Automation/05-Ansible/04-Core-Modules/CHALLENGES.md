# 🛠️ Core Modules Challenges

## Challenge 1: User Onboarding
**Objective**: Create a user with a specific setup.
1.  Module: `user`.
2.  Create user `jdoe`.
3.  Set shell to `/bin/zsh` (Ensure zsh is installed first with `package`).
4.  Add an SSH key using the `authorized_key` module.

## Challenge 2: Asset Deployment
**Objective**: Deploy a static website.
1.  Modules: `file`, `copy`.
2.  Ensure `/var/www/html/mysite` exists (Standard `0755` permissions).
3.  Create a local `index.html`.
4.  Copy it to the remote folder.

## Challenge 3: Archive Extractor
**Objective**: Download and Unzip.
1.  Modules: `unarchive`.
2.  Find a sample zip URL (or create one locally).
3.  Use `unarchive` with `remote_src=yes` to unzip it to `/tmp/extracted`.
