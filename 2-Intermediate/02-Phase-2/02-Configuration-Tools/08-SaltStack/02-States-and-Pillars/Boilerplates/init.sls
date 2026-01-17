# -----------------------------------------------------------------------------
# Name: init.sls
# Description: Standard Salt State for a web application.
# -----------------------------------------------------------------------------

# 1. Install Package
install_nginx:
  pkg.installed:
    - name: nginx

# 2. Manage File
deploy_index:
  file.managed:
    - name: /var/www/html/index.html
    - source: salt://webserver/files/index.html
    - user: www-data
    - group: www-data
    - mode: 644
    - require:
      - pkg: install_nginx

# 3. Ensure Service Running
nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: deploy_index
