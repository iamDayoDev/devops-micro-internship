# Self-Hosted Azure DevOps Agent Setup on Ubuntu

This project shows how to create and register a self-hosted Azure DevOps agent on an Ubuntu 22.04 virtual machine, connect it to Azure DevOps with a Personal Access Token (PAT), and verify it by running a pipeline from this repository.

## Objective

By the end of this setup, you will:

- Create a PAT in Azure DevOps
- Create an agent pool
- Provision an Ubuntu VM
- Install and configure the Azure Pipelines agent
- Run the agent and confirm it is online
- Execute a pipeline on the self-hosted agent

## Prerequisites

Before starting, make sure you have:

- An Azure DevOps organization
- Permission to create PATs and manage agent pools
- A Linux VM running Ubuntu 22.04 on Azure or AWS
- SSH access to the VM
- Port `22` open for SSH
- Port `443` open for outbound HTTPS communication to Azure DevOps

## Repository Files

- `README.md`: setup guide for the self-hosted agent
- `azure-pipelines.yml`: sample pipeline that runs on the self-hosted pool

## Step 1: Create a Personal Access Token (PAT)

1. Sign in to Azure DevOps.
2. Open your profile in the top-right corner.
3. Go to `Personal Access Tokens`.
4. Click `New Token`.
5. Give the token a clear name such as `self-hosted-agent-pat`.
6. Set an expiration date.
7. Grant these scopes:
   - `Agent Pools` -> `Read & manage`
   - `Build` -> `Read & execute`
8. Create the token.
9. Copy the PAT and store it securely.

Note: Azure DevOps only shows the PAT once. If you lose it, create a new one.

## Step 2: Create an Agent Pool

1. In Azure DevOps, open `Organization Settings`.
2. Select `Agent Pools`.
3. Click `Add Pool`.
4. Choose the pool type if prompted.
5. Enter a name such as `SelfHostedPool`.
6. Save the pool.

You will use this exact pool name during agent configuration and in your pipeline YAML.

## Step 3: Provision an Ubuntu VM

Create a virtual machine in AWS or Azure with the following minimum setup:

- OS: `Ubuntu 22.04`
- Size: any small VM is fine for this lab
- Open port `22` for SSH access
- Allow outbound `443` so the agent can communicate with Azure DevOps

Connect to the VM:

```bash
ssh <user>@<public_ip>
```

Example:

```bash
ssh ubuntu@203.0.113.10
```

## Step 4: Install Dependencies

Update the package index and install the dependencies required by the Azure Pipelines agent:

```bash
sudo apt update
sudo apt install -y curl tar libicu-dev
```

These packages are used for downloading, extracting, and running the agent.

## Step 5: Download the Azure Pipelines Agent

Download the Linux agent package on the VM. Replace the placeholder URL with the current agent package link from Microsoft.

```bash
wget <agent_download_url>
```

Create a working directory for the agent and extract the package:

```bash
mkdir myagent
cd myagent
mv ../<compressed_file> .
tar zxvf <compressed_file>
```

Example using the filename from this exercise:

```bash
mkdir myagent
cd myagent
mv ../vsts-agent-linux-x64-3.248.0.tar.gz .
tar zxvf vsts-agent-linux-x64-3.248.0.tar.gz
```

After extraction, the folder will contain files such as `config.sh`, `run.sh`, and `svc.sh`.

## Step 6: Configure the Agent

Run the configuration script:

```bash
./config.sh
```

When prompted, provide:

- Server URL: `https://dev.azure.com/<your-org>`
- Authentication type: `PAT`
- Personal Access Token: paste your PAT
- Agent pool: `SelfHostedPool`
- Agent name: press Enter to use the default or supply a custom name
- Work folder: `_work`

Example values:

```text
Server URL: https://dev.azure.com/my-organization
Auth type: PAT
Agent pool: SelfHostedPool
Agent name: ubuntu-agent-01
Work folder: _work
```

If setup succeeds, you should see a message confirming that the agent has been registered.

## Step 7: Run the Agent

For a quick test, start the agent in the current terminal session:

```bash
./run.sh
```

This keeps the agent online only while that shell session is active.

If you want the agent to stay running after logout or reboot, install it as a service instead:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Check service status if needed:

```bash
sudo ./svc.sh status
```

## Step 8: Verify the Agent in Azure DevOps

Go back to Azure DevOps:

1. Open `Organization Settings`
2. Select `Agent Pools`
3. Open `SelfHostedPool`
4. Confirm your agent appears
5. Check that the status is `Online`

If the agent is offline, verify:

- The VM is running
- The PAT is valid
- Outbound internet access on port `443` works
- The agent process or service is started

## Step 9: Test with a Pipeline

This repository already includes a sample pipeline in [azure-pipelines.yml](azure-pipelines.yml).

Pipeline contents:

```yaml
trigger:
- main

pool:
  name: SelfHostedPool

steps:
- script: uname -a
  displayName: 'display system info'

- script: whoami
  displayName: 'display current user'

- script: df -h
  displayName: 'display disk usage'
```

To test it:

1. Push this repository to Azure DevOps if you have not already.
2. Create a new pipeline pointing to this repository.
3. Use the existing `azure-pipelines.yml`.
4. Run the pipeline.
5. Confirm the job is picked up by the self-hosted agent.

Expected output should include:

- Linux system information from `uname -a`
- The account running the build from `whoami`
- Filesystem usage from `df -h`

## Troubleshooting

If the pipeline does not start:

- Confirm the pipeline pool name is exactly `SelfHostedPool`
- Check that the agent is listed as `Online`
- Make sure the VM can reach `dev.azure.com`
- Re-run `./config.sh remove` and configure again if registration was done incorrectly

If the agent fails to start:

- Verify dependencies are installed
- Confirm you extracted the correct Linux x64 agent package
- Make sure the PAT has not expired

If jobs remain queued:

- Check whether the pool has available permissions
- Ensure no capability or demand mismatch is blocking the job

## Security Notes

- Do not hardcode your PAT in source control
- Use a PAT with the minimum required scope
- Rotate the PAT regularly
- Delete and recreate the token immediately if it is exposed

## Result

You now have a self-hosted Azure DevOps agent running on Ubuntu and a pipeline configured to use it. Once the sample pipeline succeeds, your VM is ready to run future CI jobs through the same pool.
