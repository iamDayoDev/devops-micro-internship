# Azure DevOps Mini Finance

This project is a hands-on Azure infrastructure and automation practice repo. It uses Terraform to provision a Linux virtual machine on Azure, Ansible to configure the server, and Azure DevOps to deploy application content over SSH.

The current setup provisions an Ubuntu 22.04 VM, opens SSH and HTTP access, installs Nginx with Ansible, and includes a pipeline that can copy `index.html` to the VM and restart Nginx.

## Project Goals

- Provision Azure infrastructure with Terraform
- Configure a Linux VM with Ansible
- Practice both SSH key and password-based Ansible authentication
- Understand how to automate deployments through Azure DevOps pipelines

## Architecture

Terraform creates the following Azure resources:

- Resource group
- Virtual network
- Subnet
- Network security group with inbound SSH (`22`) and HTTP (`80`)
- Static public IP
- Network interface
- Ubuntu Linux virtual machine

Ansible then connects to the VM and:

- Updates the package cache
- Upgrades installed packages
- Installs Nginx
- Starts and enables the Nginx service

Azure DevOps can then:

- Connect to the VM through an SSH service connection
- Copy `index.html` to `/var/www/html`
- Restart Nginx

## Repository Structure

```text
.
|-- README.md
|-- terraform/
|   |-- main.tf
|   |-- outputs.tf
|   |-- providers.tf
|   |-- terraform.tfvars.example
|   `-- variable.tf
`-- ansible/
    |-- azure-pipelines.yml
    |-- inventory.ini
    `-- site.yml
```

## Prerequisites

Before you run this project, make sure you have:

- An Azure subscription
- Terraform `>= 1.3.0`
- Azure CLI installed and authenticated
- Ansible installed on your control machine
- `sshpass` installed if you plan to use password-based Ansible SSH
- An Azure DevOps project if you want to test the pipeline

Example install for `sshpass` on Ubuntu:

```bash
sudo apt update
sudo apt install -y sshpass
```

## Terraform Setup

The Terraform configuration lives in the `terraform/` folder and uses the `azurerm` provider.

### Important Variables

The most important variables are:

- `admin_username`: Linux admin username for the VM
- `admin_password`: Linux admin password for the VM
- `location`: Azure region
- `resource_group_name`: Resource group name
- `vm_name`: Virtual machine name
- `vm_size`: Azure VM size
- `vnet_name`, `subnet_name`, `nsg_name`, `public_ip_name`, `nic_name`: infrastructure naming variables

The `admin_password` variable is marked as sensitive and has no default value, so you must provide it yourself.

### Example tfvars File

Use `terraform/terraform.tfvars.example` as a starting point:

```hcl
admin_username = "azureuser"
admin_password = "ChangeMe123!"
location       = "South Africa North"
vm_name        = "mini-finance-vm"
```

### Terraform Commands

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After deployment, get the VM public IP:

```bash
terraform output public_ip_address
```

Use that IP address in your Ansible inventory.

## Ansible Setup

The Ansible playbook is in `ansible/site.yml` and currently:

- Updates apt cache
- Upgrades packages
- Installs Nginx
- Starts and enables Nginx

Basic run command:

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```

## Ansible Authentication Options

There are multiple ways to connect to the VM with Ansible. For practice, all of them are useful to understand.

### Option 1: SSH Key Authentication

This is the most common and cleanest SSH setup for Linux automation.

Example `ansible/inventory.ini`:

```ini
[web]
<vm-public-ip>

[web:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

Run:

```bash
ansible-playbook -i inventory.ini site.yml
```

Use this when:

- The VM was created with an SSH public key
- You want the most standard Linux automation flow

### Option 2: Plain Password in Inventory

This is the approach you are currently practicing with.

Example `ansible/inventory.ini`:

```ini
[web]
<vm-public-ip>

[web:vars]
ansible_user=azureuser
ansible_password=YourVmPassword
ansible_become_password=YourVmPassword
```

Run:

```bash
ansible-playbook -i inventory.ini site.yml
```

Important notes:

- This requires `sshpass` on the control machine
- This is convenient for practice, but not recommended for real shared repositories
- `ansible_become_password` is needed because the playbook uses `become: true`

### Option 3: Prompt for Password at Runtime

This avoids storing the password in the inventory file.

Example `ansible/inventory.ini`:

```ini
[web]
<vm-public-ip>

[web:vars]
ansible_user=azureuser
```

Run:

```bash
ansible-playbook -i inventory.ini site.yml -k -K
```

Flags:

- `-k` prompts for the SSH password
- `-K` prompts for the sudo/become password

Use this when:

- You want a quick manual run
- You do not want the password saved in the inventory

### Option 4: Ansible Vault

This is the better option when you want password-based auth without leaving secrets in plain text.

Create a Vault file:

```bash
cd ansible
mkdir -p group_vars/web
ansible-vault create group_vars/web/vault.yml
```

Add the following inside the encrypted file:

```yaml
ansible_password: "YourVmPassword"
ansible_become_password: "YourVmPassword"
```

Then keep `inventory.ini` simple:

```ini
[web]
<vm-public-ip>

[web:vars]
ansible_user=azureuser
```

Run with:

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

Or use a password file:

```bash
ansible-playbook -i inventory.ini site.yml --vault-password-file .vault_pass
```

Use this when:

- You want to automate password auth more safely
- You need to keep secrets out of plain-text inventory files
- You want something closer to real-world team workflows

## First-Time SSH Host Trust

If you connect to a new VM with password auth, you may see an error like:

```text
Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this
```

That happens because the host fingerprint has not been trusted yet.

You can fix it in one of these ways.

Trust the host manually:

```bash
ssh azureuser@<vm-public-ip>
```

Type `yes` when prompted, enter the password, then exit and rerun Ansible.

Or pre-load the host key:

```bash
ssh-keyscan -H <vm-public-ip> >> ~/.ssh/known_hosts
```

If the VM was recreated and the fingerprint changed:

```bash
ssh-keygen -R <vm-public-ip>
ssh-keyscan -H <vm-public-ip> >> ~/.ssh/known_hosts
```

For practice only, you can also disable host key checking for a single run:

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini site.yml
```

## Azure DevOps Pipeline

The pipeline file is `ansible/azure-pipelines.yml`.

It currently:

- Triggers on `main`
- Uses the `linux_agent_pool` agent pool
- Connects using the SSH service connection `ssh-finance-vm`
- Sets permissions on `/var/www/html`
- Copies `index.html` to the VM
- Restarts Nginx

Pipeline variables used:

- `sshService`
- `webRoot`

To make the pipeline work correctly, make sure:

- Your Azure DevOps project has an SSH service connection named `ssh-finance-vm`
- The target VM is reachable on port `22`
- Nginx is already installed on the VM
- An `index.html` file exists in the repository root before the pipeline runs

## Typical Workflow

1. Deploy infrastructure with Terraform
2. Copy the public IP output into `ansible/inventory.ini`
3. Choose an Ansible authentication method
4. Run the Ansible playbook to install and start Nginx
5. Test the VM in a browser using `http://<vm-public-ip>`
6. Use Azure DevOps to deploy updated HTML content

## Troubleshooting

### Error: `sshpass program` is missing

Install it:

```bash
sudo apt update
sudo apt install -y sshpass
```

### Error: Host key checking is enabled

Trust the host first:

```bash
ssh azureuser@<vm-public-ip>
```

Or:

```bash
ssh-keyscan -H <vm-public-ip> >> ~/.ssh/known_hosts
```

### Error: Permission denied

Check:

- The VM IP in `ansible/inventory.ini`
- The `ansible_user` value
- The password value if using password auth
- Whether password authentication is enabled on the VM
- Whether port `22` is open in the network security group

## Security Note

For learning and local practice, plain-text passwords in `inventory.ini` or `terraform.tfvars` can be useful because they make the workflow easier to see.

For any serious or shared environment, avoid committing secrets in plain text. Prefer:

- Ansible Vault
- Azure DevOps secret variables
- Azure Key Vault
- SSH key authentication

## Summary

This project is a practical mini DevOps workflow:

- Terraform provisions the Azure VM and networking
- Ansible configures the server and installs Nginx
- Azure DevOps deploys web content to the VM

It is also a good sandbox for learning the differences between SSH key auth, password auth stored in inventory, prompting at runtime, and Ansible Vault-based secret management.
