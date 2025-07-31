# Ansible Server Provisioning

This directory contains Ansible playbooks and roles for automated server provisioning and configuration management. The configurations provide server setup including security hardening, application deployment, and essential service configuration.

## Table of Contents

- [Playbooks](#playbooks)
- [Roles](#roles)
- [Configuration](#configuration)
- [Usage](#usage)
- [Prerequisites](#prerequisites)

## Features

This Ansible configuration includes tasks for:

- **Security Hardening**: SSH configuration, firewall setup, fail2ban, and user management
- **GitHub Repository Management**: Automated cloning and deployment of applications from GitHub
- **Web Server Environment**: Complete setup of web server infrastructure components
- **Nginx Configuration**: Reverse proxy setup with security hardening and SSL support
- **Docker Installation**: Container runtime setup and configuration
- **Node.js Environment**: Runtime installation and application dependency management

## Playbooks

- [`provision_server.yaml`](./provision_server.yaml) - Main server provisioning playbook
- [`setup_project.yaml`](./setup_project.yaml) - Example of a project-specific deployment playbook

## Roles

- **common** - Basic system setup and package installation
- **security** - Security hardening configurations and firewall rules
- **nginx** - Web server installation and configuration with SSL
- **nodejs** - Node.js runtime and npm package management
- **docker** - Docker engine installation and configuration
- **github** - Repository cloning and application deployment

## Configuration

### Inventory

- [`hosts`](./hosts) - Server inventory and connection details
- [`ansible.cfg`](./ansible.cfg) - Ansible configuration settings

### Variables

- [`group_vars/`](./group_vars/) - Environment-specific variable definitions
  - `all.yaml` - Global variables applied to all hosts
  - `staging.yaml` - Staging environment configurations
  - `prod.yaml` - Production environment configurations

## Prerequisites

- Ansible installed (version 2.9 or later)
- SSH access to target servers
- Sudo privileges on target servers
- Python installed on target servers

## Usage

### Basic Server Provisioning

```bash
# Deploy to all servers
ansible-playbook -i hosts provision_server.yaml

# Deploy to specific environment
ansible-playbook -i hosts provision_server.yaml -l staging
```

### Project Deployment

```bash
# Deploy application
ansible-playbook -i hosts setup_project.yaml

# Deploy with specific variables
ansible-playbook -i hosts setup_project.yaml -e "app_environment=production"
```

### Environment-Specific Deployment

```bash
# Deploy to staging
ansible-playbook -i hosts provision_server.yaml -l staging

# Deploy to production
ansible-playbook -i hosts provision_server.yaml -l prod
```

## Customization

1. **Update Inventory**: Modify [`hosts`](./hosts) with your server details
2. **Configure Variables**: Edit files in [`group_vars/`](./group_vars/) for environment-specific settings
3. **Customize Roles**: Modify role configurations in the [`roles/`](./roles/) directory
4. **Security Settings**: Review and adjust security configurations in the security role

## Security Features

- SSH key-based authentication
- Firewall configuration (UFW)
- Fail2ban intrusion prevention
- Nginx security headers and bot blocking
- User privilege management
- SSL/TLS certificate handling

The playbooks are designed to be idempotent and can be run multiple times safely to ensure desired state configuration.
