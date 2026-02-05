# Attributes and Ohai

Attributes allow you to write generic cookbooks that adapt to the target system. **Ohai** is the tool that gathers this information.

---

## 🔍 What is Ohai?
Ohai runs at the start of every Chef-client run. It "profiles" the system and collects data like:
- Operating System (`node['platform']`)
- IP Addresses (`node['ipaddress']`)
- CPU and Memory details
- Kernel version

---

## 🏷️ Types of Attributes

Chef has a hierarchy of attributes (from least to most priority):

1. **Default**: Recommended for most cases. Set in `attributes/default.rb`.
2. **Normal**: Persists on the node.
3. **Override**: Used when you absolutely must force a value.
4. **Automatic**: Set by Ohai (cannot be manually overridden).

---

## 🛠️ Using Attributes in Recipes

Instead of hardcoding paths, use node attributes to make your recipes cross-platform.

```ruby
# Use different package names for different OS families
if node['platform_family'] == 'debian'
  web_package = 'apache2'
elsif node['platform_family'] == 'rhel'
  web_package = 'httpd'
end

package web_package do
  action :install
end
```

---

## 💡 Best Practice: Data Normalization
Always use Ohai data to drive logic. This ensures that your automation works whether you're deploying to a local VM, an EC2 instance, or a physical metal server.
