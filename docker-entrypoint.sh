#!/bin/bash

# Create necessary directories if they don't exist
mkdir -p /opt/odoo/.local/share/Odoo/sessions
mkdir -p /opt/odoo/.local/share/Odoo/filestore

# Set proper permissions
chmod -R 777 /opt/odoo/.local

exec "$@"