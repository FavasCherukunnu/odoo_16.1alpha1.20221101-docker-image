# Editing Source File
1. download the odoo 16.1 alpha source file from https://nightly.odoo.com/master/nightly/deb/odoo_16.1alpha1.20221101.tar.xz
2. extract it and rename the src folder to odoo-16.1
3. copy the odoo-16.1 folder to the root of this repo
4. run the comman `docker build -t odoo:16.1 .` from this repo root path


# Running the image with postgress

## V1
### docker-compose.yaml
```
#version: '3.1'
services:
  odoo:
    image: fghcr.io/favascherukunnu/odoo-16.1:v1
    env_file: myenvfile.env
    depends_on:
      - postgres
    ports:
      - "8069:8069" #port mapping(custom-port:8069)
    volumes:
      - odoo-web-data:/var/lib/odoo
      - odoo-sessions:/opt/odoo/.local/share/Odoo/sessions
      - odoo-filestore:/opt/odoo/.local/share/Odoo/filestore
      - ./conf:/etc/odoo
      - ./custom-addons:/mnt/extra-addons
      - ./extra-addons:/mnt/extra-addons-1
    restart: always
  postgres:
    image: postgres:13
    env_file: myenvfile.env
    volumes:
      - odoo-db-data:/var/lib/pgsql/data/pgdata
    restart: always
volumes:
  odoo-web-data:
  odoo-db-data:
  odoo-filestore:
  odoo-sessions:
```
### /conf/odoo.conf
```
[options]
; This is the password that allows database operations:
admin_passwd = 123456
db_host = postgres
db_port = 5432
db_user = odoo_user
db_password = 123456
addons_path = /opt/odoo/addons,/mnt/extra-addons,/mnt/extra-addons-1
default_productivity_apps = True
```
