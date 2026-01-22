# 🛠️ Puppet Challenges

## Challenge 1: The Account Guard
**Objective**: Maintain system users.
1.  Create a manifest `users.pp`.
2.  Use the `user` resource to ensure a user `sysadmin` exists.
3.  Ensure the UID is `1500`.
4.  Remove a user `legacy_dev` by setting `ensure => absent`.

## Challenge 2: Module Structure
**Objective**: Build a module.
1.  Follow the Puppet module structure.
2.  Create `manifests/`, `files/`, and `templates/`.
3.  Write an `init.pp` that uses `file { ... source => 'puppet:///modules/mymodule/config.conf' }`.

## Challenge 3: Facter Usage
**Objective**: Use system facts.
1.  Print a message using a fact (e.g., `notify { "Operating system is ${facts['os']['family']}": }`).
2.  Create logic: Only install `bash-completion` if the OS family is RedHat.
