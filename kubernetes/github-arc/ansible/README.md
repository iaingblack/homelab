# Ansible setup for Hetzner ARC

This playbook prepares an existing Ubuntu VM for the KIND-based organization ARC setup in [`../hetzner-arc-k8s.md`](../hetzner-arc-k8s.md).

## Configure and run

Install `ansible-core` on your management machine, then copy the example file and edit its values:

```bash
cp vars.example.yml vars.yml
```

Set `hetzner_public_ip`, `ssh_user`, and `github_org` at minimum. SSH uses your local agent/default key lookup unless you set `ssh_private_key_file`. Review the KIND and ARC versions, Snap channels, API bind address, runner group, and scaling limits too.

Create the organization runner group in GitHub before running the playbook. The PAT is entered through a hidden prompt during the run if the Kubernetes secret does not already exist.

Run from this directory:

```bash
ansible-playbook -i 'localhost,' setup.yml
```

Use `--ask-become-pass` if your SSH user needs a sudo password. By default the Kubernetes API binds to loopback. If you choose a public bind address for remote administration, allow port `45001` only from trusted management IPs in the VM provider firewall.

## What it does

- Installs `ca-certificates`, `curl`, `git`, `jq`, and `snapd`.
- Installs Docker, Helm, and kubectl from the configured Snap channels.
- Downloads the configured KIND version, creates the cluster if it is absent, and installs the ARC controller and runner scale set if their Helm releases are absent.
- Prompts for the PAT and applies it as a Kubernetes secret without putting it in `vars.yml` or Ansible output.

The playbook does not provision the VM, configure its firewall, create the organization runner group, or upgrade an existing KIND cluster/ARC release. Use the upgrade procedure in the main guide for ARC chart changes.

The file `vars.yml` is ignored by Git. Keep credentials out of `vars.example.yml` and committed files.
