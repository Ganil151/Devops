# Cookbooks and Recipes

In Chef, we don't write "scripts"; we write **Policies** in the form of Recipes and Cookbooks.

---

## 📜 Definitions

### Recipes
The smallest unit of configuration. It contains a list of **Resources**.
*Example*: A recipe to ensure Nginx is installed and running.

### Cookbooks
A folder structure that holds recipes, attributes, files, and templates. Think of it as a "Project" in other languages.

---

## 📦 Core Resources (The DSL)

Chef uses a Domain Specific Language (DSL) based on Ruby to define resources.

### 1. Package
Ensures a software package is installed.
```ruby
package 'git' do
  action :install
end
```

### 2. Service
Manages the state of a system service.
```ruby
service 'nginx' do
  action [ :enable, :start ]
end
```

### 3. File / Template
Manages files on the system. Templates use `.erb` files for dynamic content.
```ruby
template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end
```

### 4. Group / User
Manages users and their permissions.
```ruby
user 'deploy' do
  comment 'Deployment User'
  home '/home/deploy'
  shell '/bin/bash'
end
```

---

## 🏁 The Chef-Client Run
When a node runs `chef-client`, it follows these steps:
1. **Load**: Identifies the recipes in its **Run List**.
2. **Compile**: Parses all Ruby code and builds a resource collection.
3. **Converge**: Goes through each resource and checks if the system matches the code. If not, it makes the change.
4. **Report**: Sends the results back to the Chef Server.
