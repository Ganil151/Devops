/etc/ansible/
   ├── inventory.ini
   ├── mysql_setup.yml
   ├── group_vars/
   │      └── mysql.yml
   ├── roles/
         └── mysql_petclinic/
                 ├── tasks/
                 │     ├── main.yml
                 │     ├── create_databases.yml
                 │     ├── create_users.yml
                 │     ├── load_schema.yml
                 │     └── load_data.yml
                 └── files/
                       ├── customers-schema.sql
                       ├── customers-data.sql
                       ├── visits-schema.sql
                       ├── visits-data.sql
                       ├── vets-schema.sql
                       └── vets-data.sql
