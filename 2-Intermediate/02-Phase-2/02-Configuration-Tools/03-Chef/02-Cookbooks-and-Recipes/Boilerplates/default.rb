# -----------------------------------------------------------------------------
# Name: default.rb
# Description: Standard Chef Recipe for Nginx.
# -----------------------------------------------------------------------------

# 1. Update Package Repository
apt_update 'update' do
  action :update
end

# 2. Install Package
package 'nginx' do
  action :install
end

# 3. Create Configuration from Template
template '/var/www/html/index.html' do
  source 'index.html.erb'
  mode '0644'
  owner 'www-data'
  group 'www-data'
  variables(
    hostname: node['hostname'],
    platform: node['platform']
  )
end

# 4. Manage Service
service 'nginx' do
  action [:enable, :start]
end
