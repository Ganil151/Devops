# -----------------------------------------------------------------------------
# Name: site.pp / class.pp
# Description: Standard Puppet Manifest for a Web Server.
# -----------------------------------------------------------------------------

class webserver {
  # 1. Ensure Package is Present
  package { 'apache2':
    ensure => installed,
  }

  # 2. File with Content and Permissions
  file { '/var/www/html/index.html':
    ensure  => file,
    content => "<h1>Managed by Puppet</h1>\n",
    mode    => '0644',
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['apache2'],
  }

  # 3. Service Management with Notify/Subscribe
  service { 'apache2':
    ensure    => running,
    enable    => true,
    subscribe => File['/var/www/html/index.html'],
  }
}

# 4. Node definition
node 'web-node-01.local' {
  include webserver
}
