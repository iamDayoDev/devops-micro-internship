# EpicBook Azure Deployment Guide

This repository provisions Azure infrastructure with Terraform and deploys the EpicBook application with Ansible.

The deployment flow is:

1. Terraform creates the Azure network, Linux VM, public IP, and private MySQL Flexible Server.
2. Ansible connects to the VM over SSH.
3. Ansible installs system packages, Nginx, Node.js dependencies, the EpicBook app, and PM2.
4. Ansible creates the application database, imports the SQL seed files, writes the app config, and starts the app behind Nginx.


## Repository Structure

| Path | Purpose |
| --- | --- |
| `terraform/azure/` | Azure infrastructure definitions |
| `terraform/azure/main.tf` | VM, networking, NSG, public IP |
| `terraform/azure/db.tf` | MySQL Flexible Server, DB subnet, private DNS |
| `terraform/azure/outputs.tf` | Terraform outputs used after provisioning |
| `ansible/site.yml` | Main playbook |
| `ansible/inventory.ini` | Target host and SSH settings |
| `ansible/group_vars/web/vars.yml` | Non-secret application variables |
| `ansible/group_vars/web/vault.yml` | Encrypted secret variables |
| `ansible/roles/common/` | Base OS prep and SSH hardening |
| `ansible/roles/nginx/` | Nginx installation and reverse proxy config |
| `ansible/roles/epicbook/` | App deployment, DB import, config, PM2 |

## What Is Hardcoded in This Repo

Before deploying, it helps to know what this repository assumes:

- The VM admin user is `azureuser` by default.
- The default Azure location is `South Africa North`.
- The app is cloned from `https://github.com/pravinmishraaws/theepicbook.git`.
- The app is deployed to `/var/www/epicbook`.
- Nginx listens on port `80`.
- Nginx proxies traffic to `127.0.0.1:8080`.
- PM2 starts the app with `server.js`.
- The generated app database config uses MySQL over SSL.
- The playbook sets `NODE_ENV` to `development`.

If any of these assumptions need to change, update the relevant Terraform or Ansible variable files before running the deployment.

## Prerequisites

Install the following on your control machine:

- Terraform `>= 1.3.0`
- Ansible
- Azure CLI
- OpenSSH client
- Git`

Authenticate to Azure before running Terraform:

```bash
az login
az account set --subscription "<your-subscription-id-or-name>"
```

## SSH Key Requirements

Terraform expects an SSH public key, and Ansible expects the matching private key.

- Terraform variable: `ssh_public_key`
- Default value in this repo: `~/.ssh/id_ed25519.pub`
- Inventory private key path: `~/.ssh/id_ed25519`

If you are deploying from Windows, it is safer to use absolute paths instead of `~` if path expansion does not work in your shell.

Example:

```hcl
ssh_public_key = "C:/Users/USER/.ssh/id_ed25519.pub"
```

And in `ansible/inventory.ini`:

```ini
ansible_ssh_private_key_file=C:/Users/USER/.ssh/id_ed25519
```

## Step 1: Configure Terraform

Terraform variables are defined in `terraform/azure/variables.tf`, and values are currently read from `terraform/azure/terraform.tfvars`.

At minimum, review these values:

Example `terraform.tfvars`:

```hcl
admin_username      = "azureuser"
location            = "South Africa North"
vm_name             = "ansible-epicbook-vm"
resource_group_name = "ansible-epicbook-rg"
ssh_public_key      = "C:/Users/USER/.ssh/id_ed25519.pub"
db_username         = "<mysql-admin-user>"
db_password         = "<strong-mysql-password>"
```

## Step 2: Provision Azure Infrastructure

From the Terraform directory:

```bash
cd terraform/azure
terraform init
terraform plan
terraform apply
```

When the apply finishes, collect the outputs:

- Copy the `public_ip_address` value for the VM public IP from terraform output
- Copy the `epicbook_db_endpoint` value for the MySQL Flexible Server FQDN from terraform output

You will need both values for the Ansible configuration:

- `public_ip_address`: used in the Ansible inventory and optionally as the Nginx `server_name`
- `epicbook_db_endpoint`: used as the database host in the Ansible vault

## Step 3: Update the Ansible Inventory

Edit `ansible/inventory.ini` and replace the host IP with the public IP from Terraform.

Example:

```ini
[web]
<PUBLIC_IP>

[web:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=C:/Users/USER/.ssh/id_ed25519
```

If you change `admin_username` in Terraform, make sure `ansible_user` matches it.

## Step 4: Update Non-Secret Ansible Variables

Edit `ansible/group_vars/web/vars.yml`.

Important values in this file:

- `app_repo`: Git repository to clone onto the VM
- `app_dest`: deployment directory on the VM
- `server_name`: currently used by the Nginx virtual host
- `backend_host`: local upstream host for the Node.js app
- `backend_port`: local upstream port for the Node.js app
- `app_start_file`: PM2 startup file
- `NODE_ENV`: application environment value passed to PM2

After Terraform creates the VM, update:

- `server_name` to the VM public IP, or to your DNS name if you are using a domain

## Step 5: Create or Update the Ansible Vault

The file `ansible/group_vars/web/vault.yml` stores secret values and is expected to stay encrypted.

The playbook expects these variables:

- `vault_db_host`
- `vault_db_user`
- `vault_db_name`
- `vault_db_port`
- `vault_db_password`

If you are creating the file for the first time:

```bash
ansible-vault create ansible/group_vars/web/vault.yml
```

If the file already exists:

```bash
ansible-vault edit ansible/group_vars/web/vault.yml
```

Use content in this shape:

```yaml
vault_db_host: "<terraform output epicbook_db_endpoint>"
vault_db_user: "<same value as db_username in terraform.tfvars>"
vault_db_name: "<database-name-to-create>"
vault_db_port: 3306
vault_db_password: "<same value as db_password in terraform.tfvars>"
```

Notes:

- `vault_db_host` should be the MySQL Flexible Server FQDN from Terraform output.
- `vault_db_user` and `vault_db_password` should match the MySQL admin credentials used by Terraform.
- `vault_db_name` is the database that Ansible will create before importing the SQL files.

## Step 6: Run the Ansible Playbook

From the Ansible directory:

```bash
cd ansible
ansible all -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

What the playbook does:

### Common Role

- Updates and upgrades apt packages
- Installs baseline packages: `git`, `curl`, `unzip`, `software-properties-common`
- Disables root SSH login

### Nginx Role

- Installs Nginx
- Creates `/etc/nginx/sites-available/epicbook`
- Enables the EpicBook site
- Removes the default Nginx site
- Starts and enables Nginx

### EpicBook Role

- Installs `nodejs`, `npm`, `mysql-client`, and `python3-pymysql`
- Creates `/var/www/epicbook`
- Clones the EpicBook application repository
- Runs `npm install`
- Installs PM2 globally
- Creates the application database on Azure MySQL
- Imports the SQL dump files from the app repo
- Renders `config/config.json`
- Starts the app with PM2
- Saves the PM2 process list

## Step 7: Verify the Deployment

After the playbook succeeds, verify the deployment in the following order.

Open the application:

```bash
curl http://<PUBLIC_IP>
```

Or visit:

```text
http://<PUBLIC_IP>
```

SSH into the VM:

```bash
ssh azureuser@<PUBLIC_IP>
```

On the VM, check Nginx:

```bash
sudo nginx -t
sudo systemctl status nginx
```

Check the app process:

```bash
pm2 ls
```

Check that the app directory exists:

```bash
ls -la /var/www/epicbook
```

## Application Runtime Details

The deployed runtime currently behaves like this:

- Public traffic enters through Nginx on port `80`
- Nginx forwards requests to `127.0.0.1:8080`
- The Node.js app is started by PM2 using `server.js`
- The app database config is written to `/var/www/epicbook/config/config.json`
- The app connects to Azure MySQL using SSL settings generated by Ansible

## Redeploying After Changes

### If only the application or Ansible configuration changed

Rerun the playbook:

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

### If Terraform recreated the VM or public IP

Do these in order:

1. Run `terraform apply`
2. Collect the new outputs
3. Update `ansible/inventory.ini`
4. Update `ansible/group_vars/web/vars.yml` if `server_name` changed
5. Rerun the Ansible playbook

### If the app code changed but PM2 does not refresh cleanly

SSH into the VM and restart the process manually:

```bash
pm2 restart epicbook
pm2 save
```

## Destroying the Environment

When you are finished and want to avoid Azure charges:

```bash
cd terraform/azure
terraform destroy
```

This is especially important because the MySQL Flexible Server SKU in this configuration can incur noticeable cost if left running.

## Troubleshooting

### SSH connection fails

Check:

- The public IP in `ansible/inventory.ini` is current
- `ansible_user` matches the Terraform `admin_username`
- The private key in `inventory.ini` matches the public key used by Terraform
- Port `22` is reachable on the VM public IP

### Ansible cannot connect to MySQL

Check:

- `vault_db_host` matches the Terraform MySQL output
- `vault_db_user` and `vault_db_password` match the Terraform MySQL admin credentials
- `vault_db_port` is `3306`
- The VM and DB are still in the same virtual network created by Terraform

### Database import throws errors on reruns

The SQL import task is configured with `ignore_errors: true`.

That means:

- First deployment usually imports the schema and seed data
- Later deployments may report duplicate table or duplicate data errors
- Those errors may be harmless if the database is already populated

### Nginx returns `502 Bad Gateway`

Check:

- The Node.js app is running in PM2
- The app is actually listening on `127.0.0.1:8080`
- The generated app config has the correct database values

Useful commands:

```bash
pm2 logs epicbook
sudo tail -f /var/log/nginx/error.log
```

### App does not come back after a reboot

This playbook runs `pm2 save`, but it does not configure a PM2 startup service.

If required, configure PM2 startup manually on the VM:

```bash
pm2 startup
pm2 save
```

## Security and Production Notes

This deployment works, but there are a few production improvements worth making:

- Use Ansible Vault for all secrets and avoid committing plaintext secrets
- Keep Terraform state secure because it may contain sensitive values
- Restrict SSH access to trusted IPs instead of leaving it open to `*`
- Add HTTPS with a real domain and TLS certificates
- Consider setting `NODE_ENV` to `production`
- Consider automating inventory generation from Terraform outputs
- Consider configuring PM2 startup persistence during provisioning

## Quick Command Summary

```bash
# Azure auth
az login
az account set --subscription "<subscription>"

# Terraform
cd terraform/azure
terraform init
terraform apply
terraform output public_ip_address
terraform output epicbook_db_endpoint

# Ansible
cd ../../ansible
ansible-galaxy collection install community.mysql
ansible all -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

## Final Notes

This repository follows a clean split of responsibilities:

- Terraform provisions infrastructure
- Ansible configures the server and deploys the app

That makes it easy to reprovision infrastructure when needed and rerun the application deployment independently.
