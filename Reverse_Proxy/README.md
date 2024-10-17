# Reverse Proxy

This folder contains the sample configuration and setup files for provisioning an Ubuntu server and deploying NGINX reverse proxy using Ansible.

## Structure

- `ansible.cfg`: Configuration file for Ansible, specifying the inventory file location.
- `inventories/`: Directory containing inventory files for Ansible.
  - `hosts`: Inventory file listing the hosts for the reverse proxy setup.
- `roles/`: Directory containing Ansible roles for setting up security firewalls, docker and the reverse proxy.
  - `common/`: Common roles used across different setups.
  - `...`: Other specific roles for the reverse proxy setup.
- `setup_infrastructure.yaml`: Ansible playbook to set up the reverse proxy infrastructure.

## Usage

1. **Configure Ansible:**

   - Ensure the `ansible.cfg` file is correctly set up to point to the `inventories/hosts` file.

2. **Define Hosts:**

   - Edit the `inventories/hosts` file to list the hosts that will be part of the reverse proxy setup.

3. **Run Playbook:**
   - Execute the `setup_infrastructure.yaml` playbook to set up the reverse proxy infrastructure:
     ```sh
     ansible-playbook setup_infrastructure.yaml
     ```
