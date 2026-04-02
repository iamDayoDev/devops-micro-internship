# Azure Static Website with Ansible and Terraform

A complete Infrastructure-as-Code (IaC) solution for deploying a static website on Microsoft Azure using **Terraform** for infrastructure provisioning and **Ansible** for configuration management.

## Project Overview

This project demonstrates a modern DevOps workflow by automating the deployment of a static website on Azure. It combines:

- **Terraform**: Infrastructure provisioning (networking, VM, security)
- **Ansible**: Server configuration and application deployment
- **Azure**: Cloud platform hosting the infrastructure
- **Nginx**: Web server serving the static content

The project is designed as part of the DevOps Micro Internship (DMI) – Cohort 2 curriculum.

---

### Deployment Flow

1. **Infrastructure Provisioning** (Terraform)
   - Create Resource Group
   - Create Virtual Network and Subnet
   - Create Network Security Group with firewall rules
   - Create Public IP address
   - Create Network Interface
   - Create Linux Virtual Machine

2. **Server Configuration** (Ansible)
   - Install Nginx web server
   - Start and enable Nginx service
   - Deploy static website content
   - Restart Nginx to apply changes

---

## Directory Structure

```
ansible-azure-static-website/
├── README.md                 # Project documentation
├── terraform/                # Terraform IaC configuration
│   ├── main.tf              # Primary infrastructure resources
│   ├── variables.tf         # Input variables (defaults)
│   ├── outputs.tf           # Output values (public IP)
│   └── providers.tf         # Azure provider configuration 
└── ansible/                  # Ansible playbooks & inventory
    ├── site.yml             # Main playbook (install & deploy)
    ├── inventory.ini        # Host inventory
    └── src/
        └── index.html       # Static website content
```

## Prerequisites

Before deploying this project, ensure you have:

### Required Software
- **Terraform** (v1.0+) - [Download](https://www.terraform.io/downloads.html)
- **Ansible** (v2.9+) - `pip install ansible`
- **Azure CLI** - [Installation guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **SSH Key Pair** - Generate with `ssh-keygen -t ed25519`

### Azure Account
- Active Azure subscription
- Sufficient permissions to create resources (Contributor role)

### Environment Setup
```bash
# Install Ansible
pip install ansible

# Authenticate with Azure
az login

# Set your subscription (if multiple)
az account set --subscription "<SUBSCRIPTION_ID>"

# Verify SSH key exists
ls ~/.ssh/id_ed25519.pub
```

## Configuration

### Terraform Variables (`terraform/variables.tf`)

Customize defaults before deployment:

| Variable | Default | Description |
|----------|---------|-------------|
| `admin_username` | `azureuser` | VM administrator username |
| `location` | `South Africa North` | Azure region for resources |
| `vm_name` | `ansible-static-website-vm` | Virtual machine name |
| `resource_group_name` | `ansible-static-website-rg` | Azure resource group name |
| `ssh_public_key` | `~/.ssh/id_ed25519.pub` | Path to your SSH public key |

**To override defaults**, create a `terraform.tfvars` file:
```hcl
# terraform.tfvars
location       = "East US"
admin_username = "adminuser"
```

### Ansible Inventory (`ansible/inventory.ini`)

Update with the public IP of your VM after Terraform deployment:

```ini
[web]
<PUBLIC_IP_ADDRESS>

[web:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

The inventory is pre-configured with sample IP `20.87.3.80`. Replace this with your actual VM's public IP.

---

## Deployment Instructions

### Step 1: Initialize Terraform

```bash
cd terraform/
terraform init
```

This downloads Azure provider plugins and prepares the working directory.

### Step 2: Plan the Infrastructure

```bash
terraform plan
```

Review the resources that will be created. Check:
- Resource group and networking components
- VM size and image specifications
- Security group rules (SSH, HTTP)


### Step 3: Apply Terraform Configuration

```bash
terraform apply
```

**Important**: Accept the confirmation by typing `yes`

The deployment takes approximately 2-3 minutes. Once complete, Terraform outputs the public IP address:

Copy Public IP Address from terraform output

### Step 5: Update Ansible Inventory

Edit `ansible/inventory.ini` with the public IP from Step 4:

```ini
[web]
20.87.3.XX  # Replace XX with actual values

[web:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

### Step 6: Run Ansible Playbook

```bash
cd ../ansible/
ansible-playbook -i inventory.ini site.yml
```

### Step 7: Verify Deployment

Access your website in a browser:

```
http://<PUBLIC_IP_ADDRESS>
```

You should see the DevOps Micro Internship (DMI) homepage with styling and content.

Test from command line:
```bash
curl http://<PUBLIC_IP_ADDRESS>
```

---

## What Gets Deployed

### Azure Resources (via Terraform)

| Resource | Name | Details |
|----------|------|---------|
| Resource Group | `ansible-static-website-rg` | Container for all resources |
| Virtual Network | `static-website-vnet` | Network range: 10.0.0.0/16 |
| Subnet | `static-website-subnet` | Subnet range: 10.0.1.0/24 |
| Public IP | `static-website-pip` | Static, Standard SKU |
| Network Interface | `static-website-nic` | Connects VM to subnet |
| Network Security Group | `static-website-nsg` | Firewall with SSH & HTTP rules |
| Virtual Machine | `ansible-static-website-vm` | Ubuntu 22.04 LTS, Standard_D2s_v3 |

### Server Configuration (via Ansible)

- **Web Server**: Nginx (latest from apt)
- **Website Root**: `/var/www/html/`
- **Website Content**: `index.html` (DevOps DMI homepage)
- **Service**: Nginx enabled for auto-startup

---

## Cleanup & Cost Management

### Destroy All Resources

When done, remove all Azure resources to avoid charges:

```bash
cd terraform/
terraform destroy
```

## Learning Outcomes

After completing this project, you'll understand:

✅ **Terraform Basics**
- Writing IaC configurations
- Managing Azure resources
- State file management
- Outputs and variables

✅ **Ansible Fundamentals**
- Creating playbooks
- Managing inventory
- Using modules (apt, service, copy)
- SSH-based automation

✅ **Azure Networking**
- Virtual Networks and Subnets
- Network Security Groups
- Public/Private IP addresses
- VM provisioning on Linux

✅ **DevOps Best Practices**
- Infrastructure as Code
- Configuration Management
- Automated deployments
- SSH key-based authentication

---

## License

This project is part of the DevOps Micro Internship curriculum.

---
