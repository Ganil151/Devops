# Environments and Data Bags

Scale requires organization and security. Environments and Data Bags help you manage complex infrastructures.

---

## 🌍 Environments
Environments allow you to separate different stages of your infrastructure (e.g., `Development`, `Staging`, `Production`).
- **Purpose**: Lock cookbook versions for specific environments.
- **Example**: "Keep Production on Webserver Cookbook version 1.2.0, while Staging moves to 1.3.0."

---

## 🛍️ Data Bags
Data Bags are global JSON objects stored on the Chef Server. They are shared across all nodes.
- **Use Case**: User lists, common configuration settings, and group definitions.

### 🔐 Encrypted Data Bags
Use these for secrets like database passwords, SSL certificates, or API keys.
- **Mechanism**: Data is encrypted on the server; nodes require a shared "secret key" file to decrypt it locally.

---

## 🏗️ Example Logic
```ruby
# Loading a data bag item
user_data = data_bag_item('users', 'bob')

user user_data['id'] do
  comment user_data['full_name']
  home "/home/#{user_data['id']}"
  action :create
end
```

---

## 💡 Summary
- **Environments**: Control which **version** of the code runs where.
- **Data Bags**: Store **global data** that many cookbooks might need.
