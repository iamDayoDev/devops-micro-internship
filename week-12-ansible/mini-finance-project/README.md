# Mini Finance Deployment on Azure with Terraform and Ansible

This project deploys the Mini Finance static web application to Microsoft Azure using a clean separation of concerns:

- Terraform provisions the Azure infrastructure.
- Ansible configures the server and deploys the application.

The goal is to create a fast, repeatable workflow for standing up a public demo environment with secure SSH access and HTTP access for the site.

## Project Overview

The repository currently contains:

- Azure infrastructure code in `terraform/`
- Ansible inventory and playbook files in `ansible/`
- This deployment guide in `README.md`

## Project Structure

```text
mini-finance-project/
|-- README.md
|-- ansible/
|   |-- inventory.ini
|   `-- site.yml
`-- terraform/
    |-- main.tf
    |-- outputs.tf
    `-- variables.tf
```

Notes:

- The provider configuration is currently defined in `terraform/main.tf` instead of a separate `providers.tf`.

## What Terraform Provisions

The Terraform configuration in this repository creates the following Azure resources:

- Resource Group
- Virtual Network with CIDR `10.0.0.0/16`
- Subnet with CIDR `10.0.1.0/24`
- Network Security Group
- NSG inbound rules for:
  - SSH on port `22`
  - HTTP on port `80`
- Public IP address
- Network Interface
- Ubuntu 22.04 Linux Virtual Machine

Current implementation details from `terraform/main.tf`:

- VM size: `Standard_B1s`
- OS image: Canonical Ubuntu Server 22.04 LTS
- Authentication: SSH public key only
- Password authentication: disabled

## What Ansible Does

The Ansible playbook in `ansible/site.yml` is organized into multiple plays that handle deployment in stages:

1. Install and start Nginx
2. Clone the Mini Finance application and copy site files into `/var/www/html/`
3. Write an Nginx site configuration
4. Restart Nginx so the new configuration is applied

This keeps infrastructure provisioning and application configuration clearly separated.

## Prerequisites

Before you begin, make sure you have:

- An Azure subscription
- Terraform installed
- Ansible installed
- Git installed
- An SSH key pair available on your control machine
- Azure CLI installed and authenticated with `az login`

Recommended control machine:

- Linux, macOS, or WSL on Windows for running Ansible

Important path note:

- The default Terraform variable for `ssh_public_key` is `~/.ssh/id_ed25519.pub`
- If you are running Terraform from Windows Command Prompt or PowerShell, use an absolute path such as `C:/Users/USER/.ssh/id_ed25519.pub`

## Terraform Variables

The current defaults in `terraform/variables.tf` are:

| Variable | Default |
|---|---|
| `admin_username` | `azureuser` |
| `location` | `South Africa North` |
| `vm_name` | `mini-finance-vm` |
| `resource_group_name` | `mini-finance-rg` |
| `ssh_public_key` | `~/.ssh/id_ed25519.pub` |

You can either edit `terraform/variables.tf` directly or create a `terraform.tfvars` file inside the `terraform/` directory.

Example:

```hcl
admin_username      = "azureuser"
location            = "South Africa North"
vm_name             = "mini-finance-vm"
resource_group_name = "mini-finance-rg"
ssh_public_key      = "C:/Users/USER/.ssh/id_ed25519.pub"
```

## Terraform Output

The repository currently exposes this Terraform output from `terraform/outputs.tf`:

```hcl
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}
```

## Deployment Guide

### 1. Authenticate to Azure

```bash
az login
```

If you use multiple subscriptions, set the correct one:

```bash
az account set --subscription "<subscription_name_or_id>"
```

### 2. Initialize Terraform

Move into the Terraform directory:

```bash
cd terraform
```

Initialize the working directory:

```bash
terraform init
```

### 3. Review the Execution Plan

```bash
terraform plan
```

This shows the Azure resources Terraform will create before you apply changes.

### 4. Create the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

After a successful apply, Terraform will provision:

- Resource group
- Networking
- NSG rules for `22` and `80`
- Ubuntu VM
- Public IP address

### 5. Get the VM Public IP

Save this value because you will use it for SSH and for the Ansible inventory.

### 6. Test Passwordless SSH

Replace `<admin_user>` and `<public_ip>` with your values:

```bash
ssh <admin_user>@<public_ip> "hostname"
```

Expected result:

- The command should connect without asking for a password
- The VM hostname should be returned

### 7. Update the Ansible Inventory

Open `ansible/inventory.ini` and replace the placeholders:

```ini
[web]
<public_ip>

[web:vars]
ansible_user=<admin_user>
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

If you are running from Windows without WSL, use a full path for the private key that Ansible can resolve.

### 8. Run the Ansible Playbook

Move into the Ansible directory:

```bash
cd ../ansible
```

Run the playbook:

```bash
ansible-playbook -i inventory.ini site.yml
```

This will:

- Install Nginx
- Start and enable the Nginx service
- Clone the Mini Finance repository
- Copy the site files into `/var/www/html/`
- Replace the default Nginx site configuration
- Restart Nginx

### 9. Verify the Deployment

Open the site in your browser:

```text
http://<public_ip>
```

You can also verify from the command line:

```bash
curl -I http://<public_ip>
```

Expected result:

- An HTTP `200 OK` response
- The Mini Finance site loads in the browser

## Ansible Playbook Breakdown

The current `ansible/site.yml` contains four plays:

### Play 1: Install and Start Nginx Web Server

- Targets the `web` host group
- Uses privilege escalation with `become: yes`
- Installs Nginx
- Starts and enables the Nginx service

### Play 2: Deploy Mini Finance Website

- Clones the application repository to `/tmp/mini_finance`
- Copies application files into `/var/www/html/`
- Sets ownership to `www-data:www-data`

### Play 3: Configure Nginx to Serve the Site

- Replaces the default site config in `/etc/nginx/sites-available/default`
- Sets the web root to `/var/www/html`
- Uses `try_files` so the site can resolve to `index.html`

### Play 4: Restart Nginx After Configuration

- Restarts the Nginx service to apply the configuration changes

## Current Implementation Notes

- The repository URL currently configured in `ansible/site.yml` is:

```text
https://github.com/pravinmishraaws/mini_finance.git
```

## Recommended End-to-End Workflow

Use this sequence every time you want to redeploy the full environment:

1. Run `terraform init`
2. Run `terraform plan`
3. Run `terraform apply`
4. Copy the public IP from the Terraform output
5. Update `ansible/inventory.ini`
6. Run `ansible-playbook -i inventory.ini site.yml`
7. Validate the site in a browser or with `curl`

## Cleanup

When you are done with the environment, destroy the Azure resources to avoid ongoing charges:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted.

## Security Note

This project is suitable for a demo or learning environment. The current NSG rules allow:

- SSH from any source
- HTTP from any source

For production or team environments, restrict SSH access to trusted IP ranges and use stronger operational controls around secrets, state storage, and change management.
