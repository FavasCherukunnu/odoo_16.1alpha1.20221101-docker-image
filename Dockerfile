# Use a more specific base image tag for better reproducibility
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Define build arguments that can be overridden
ARG ODOO_USER=odoo
ARG ODOO_GROUP=odoo

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/opt/odoo

# Create Odoo user and set up directory structure
RUN groupadd -r ${ODOO_GROUP} && \
    useradd -r -g ${ODOO_GROUP} -d /opt/odoo -s /bin/bash ${ODOO_USER} && \
    mkdir -p /opt/odoo /var/lib/odoo /var/log/odoo /etc/odoo && \
    chown -R ${ODOO_USER}:${ODOO_GROUP} /opt/odoo /var/lib/odoo /var/log/odoo /etc/odoo

# Install system packages and dependencies
# Using --no-install-recommends to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        build-essential \
        wget \
        curl \
        nodejs \
        npm \
        git \
        libxml2-dev \
        libxslt1-dev \
        libsasl2-dev \
        libldap2-dev \
        libssl-dev \
        libjpeg-dev \
        libpq-dev \
        libffi-dev \
        fonts-liberation \
        wkhtmltopdf \
        postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment and install Python dependencies
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Odoo files first, so we can access requirements.txt
COPY --chown=${ODOO_USER}:${ODOO_GROUP} ./odoo-16.1 /opt/odoo/

# Install Python packages from Odoo's requirements.txt
RUN pip3 install --no-cache-dir wheel && \
    pip3 install --no-cache-dir -r /opt/odoo/requirements.txt

# Create directory for custom addons
RUN mkdir -p /opt/odoo/custom-addons && \
    chown -R ${ODOO_USER}:${ODOO_GROUP} /opt/odoo/custom-addons

# Set up volumes
VOLUME ["/var/lib/odoo", "/opt/odoo/custom-addons", "/var/log/odoo"]

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Switch to Odoo user
USER ${ODOO_USER}

# Set the working directory
WORKDIR /opt/odoo

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD curl -f http://localhost:8069/web/health || exit 1

# Default command to run Odoo
CMD ["python3", "odoo-bin", "-c", "/etc/odoo/odoo.conf","--addons-path", "/opt/odoo/addons"]