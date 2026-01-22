# 🛠️ Chef Challenges

## Challenge 1: The User Manager
**Objective**: Automate user creation.
1.  Create a recipe `users.rb`.
2.  Use the `user` resource to create a user `web_admin`.
3.  Set a `home` directory and `shell`.
4.  Use the `directory` resource to create `/home/web_admin/.ssh`.

## Challenge 2: Attribute-driven logic
**Objective**: Change behavior based on platform.
1.  In `attributes/default.rb`, set `default['myapp']['package'] = 'apache2'`.
2.  In `recipes/default.rb`, use the attribute to install the package.
3.  Add logic: If `node['platform'] == 'centos'`, use `httpd` instead.

## Challenge 3: File content injection
**Objective**: Use the `file` resource.
1.  Create a file `/tmp/version.txt`.
2.  Inject the date and time using Ruby's `Time.now`.
