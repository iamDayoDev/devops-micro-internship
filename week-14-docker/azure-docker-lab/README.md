# Azure Docker Lab

This project provisions an Ubuntu virtual machine in Microsoft Azure with Terraform and uses `cloud-init` to bootstrap Docker during first boot. After the VM is created, a static website is containerized with Docker and served through Nginx on port `80`.

## Project Goal

The goal of this lab is to:

- Provision Azure infrastructure with Terraform.
- Automatically install and start Docker on the VM with `cloud-init`.
- Deploy a static website inside a Docker container.
- Expose the site over HTTP.

## Infrastructure Created

The Terraform configuration in [main.tf](./main.tf) creates:

- A resource group in `South Africa North`
- A virtual network and subnet
- A network security group with inbound rules for `22` and `80`
- A network interface
- A static public IP address
- A Linux virtual machine running Ubuntu

## Cloud-Init Bootstrap

The VM uses `custom_data` with a `cloud-init` configuration to prepare the server during first boot. This means Docker is installed automatically as part of the VM setup instead of being installed manually later.

### What the cloud-init script does

The bootstrap configuration:

- Updates the package list
- Upgrades installed packages
- Installs supporting packages such as `curl`, `gnupg`, and `lsb-release`
- Installs Docker with `apt-get install -y docker.io`
- Enables Docker so it starts on boot
- Starts the Docker service immediately
- Adds the VM admin user to the `docker` group

### Why this matters

Using `cloud-init` makes the VM reproducible. Every time the VM is created from Terraform, Docker is installed the same way without needing manual setup steps.

## Verifying Cloud-Init

After the VM was created, the bootstrap process was verified from:

```bash
/var/log/cloud-init-output.log
```

This log is useful for confirming that the `cloud-init` commands ran successfully and for troubleshooting if package installation or service startup fails.

## Docker Task Completed on the VM

After Docker was installed by `cloud-init`, the next task on the VM was to containerize and run a static website.

### Step 1: Clone the project

The static website source code was downloaded to the VM:

```bash
git clone https://github.com/pravinmishraaws/Azure-Static-Website.git
cd Azure-Static-Website
```

This repository contains the website files that Nginx will serve.

### Step 2: Create the Dockerfile

A `Dockerfile` was created in the project directory:

```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY . /usr/share/nginx/html
EXPOSE 80
```

### What this Dockerfile does

- `FROM nginx:alpine` uses a lightweight Nginx image as the base.
- `RUN rm -rf /usr/share/nginx/html/*` removes the default Nginx welcome page.
- `COPY . /usr/share/nginx/html` copies the cloned static website files into the Nginx web root.
- `EXPOSE 80` documents that the container serves traffic on port `80`.

In simple terms, this image turns the static website into a small web server container.

### Step 3: Build the Docker image

The image was built locally on the VM:

```bash
docker build -t static-site:latest .
```

### What this command does

- `docker build` creates an image from the `Dockerfile`
- `-t static-site:latest` assigns the image name and tag
- `.` tells Docker to use the current directory as the build context

At the end of this step, the website existed as a reusable Docker image called `static-site:latest`.

### Step 4: Run the container

The container was started with:

```bash
docker run -d --name static-site \
  -p 80:80 \
  --restart unless-stopped \
  static-site:latest
```

### What this command does

- `-d` runs the container in detached mode
- `--name static-site` gives the container a readable name
- `-p 80:80` maps VM port `80` to container port `80`
- `--restart unless-stopped` ensures the container restarts automatically after reboot unless it was explicitly stopped
- `static-site:latest` tells Docker which image to run

Because the Azure network security group already allows inbound HTTP traffic on port `80`, the website becomes reachable from the VM's public IP address.

### Step 5: Confirm the container is running

Verification was done with:

```bash
docker ps
```

This confirms that the `static-site` container is running and listening on port `80`.


## Useful Commands

```bash
terraform init
terraform plan
terraform apply
ssh <username>@<public-ip>
cat /var/log/cloud-init-output.log
docker ps
docker logs static-site
```

## Notes

- This setup is intended for learning and lab practice.
- The VM currently uses password authentication, which is not recommended for production.
- If the VM is recreated, `cloud-init` will reinstall Docker automatically.

## Outcome

This lab demonstrates basic infrastructure automation and container deployment on Azure. Terraform provisions the VM, `cloud-init` bootstraps Docker, and Docker runs the static website with Nginx in a repeatable way.
