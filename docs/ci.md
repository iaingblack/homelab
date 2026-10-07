# Continuous integration

The repository is a collection of homelab configurations and standalone projects, not one application with a root build. The new CI job follows the existing `master_bitcoincountdown.yml` workflow for `Project/ExchangeLiquidityCountdown`: it installs that project's `requirements.txt`, builds the same ZIP deployment archive in `/tmp`, checks installed dependency consistency with `pip check`, and compiles its Python files. There is currently no automated unit test suite or configured linter for this project.

The main CI workflow runs for changes to `Project/ExchangeLiquidityCountdown/**` on `master`, same-repository pull requests targeting `master`, and manual dispatch. Fork pull requests are skipped so untrusted code does not run on the persistent self-hosted runner. The existing Azure build and deployment workflow remains separate.

## Set up the self-hosted Docker VM

The Linux VM hosts two things directly: the GitHub Actions runner service and Docker Engine. When a workflow job declares `container:`, the runner asks the VM's Docker Engine to pull and start the job image. The CI image does not run its own Docker daemon. Your development workstation does not need Docker, and the VM's Docker API does not need to be exposed over the network.

### Prepare Docker Engine on the VM

Install Docker Engine using the instructions for the VM's Linux distribution, then enable it at boot:

```bash
sudo systemctl enable --now docker
```

Use the local Docker socket (`unix:///var/run/docker.sock` by default) and leave `DOCKER_HOST` unset. The Linux account that runs the Actions runner service must be able to use Docker without `sudo`. For a standard rootful Docker installation, add that account to the `docker` group:

```bash
sudo usermod -aG docker <runner-user>
```

Restart the runner service after changing group membership so it picks up the new permission. Check Docker access as the runner account:

```bash
sudo -u <runner-user> docker info
```

Membership in the `docker` group grants powerful control of the VM. Only allow trusted repositories and workflows to use this runner.

### Register the GitHub Actions runner

1. In this repository on GitHub, open **Settings → Actions → Runners → New self-hosted runner**. Choose Linux and the VM's processor architecture.
2. Follow GitHub's generated commands on the VM to download and extract the runner application. Keep the runner in its own directory, such as `~/actions-runner`.
3. Run the generated `config.sh` command for `https://github.com/iaingblack/homelab`. Use the temporary registration token promptly; it expires and should not be saved in the repository.
4. Keep the default `self-hosted` and `linux` labels. The main job routes with `runs-on: [self-hosted, linux]`.

GitHub documents [adding a self-hosted runner](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners) and provides the current runner download and configuration commands in the repository settings page.

### Run the runner as a service

From the runner installation directory, install and start the service:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
```

On Linux with systemd, installing the service configures the runner to start when the VM boots. Check **Settings → Actions → Runners** and confirm the runner is **Idle**. GitHub's [service instructions](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application?platform=linux) also cover stopping and removing the service.

Keep the runner application current. The workflows use Node.js 24 actions and require runner version 2.327.1 or newer. The runner VM also needs outbound HTTPS access to GitHub and GHCR so it can receive jobs and pull the private CI image.

### What runs inside the job container

The main CI job uses the labels `self-hosted` and `linux`, then runs inside `ghcr.io/iaingblack/homelab-ci:v1`. The Dockerfile is [build/ci/Dockerfile](../build/ci/Dockerfile). It contains Python 3.12, Bash, Git, `zip`, OpenSSH client tools, Ansible Core 2.21.5, `ansible-lint` 26.9.0, `yamllint` 1.38.0, Terraform 1.13.0 managed by `tfenv`, Packer 1.16.1, Task 3.53.1, `kubectl` 1.37.1, and Helm 3.22.0. The Terraform pin matches the repository's Terraform Taskfiles. Ansible collections are not bundled; install the collections each playbook needs with `ansible-galaxy`.

The job uses `GITHUB_TOKEN` to pull the private GHCR package. The runner VM's Docker Engine performs that pull and starts the container. The image does not include a Docker daemon or cloud provider CLIs. Workflows that need to run Docker commands inside the container must separately provide a Docker client and access to the VM's socket.

This runner is registered to the `homelab` repository. Repository-level runners serve one repository; sharing one registration across repositories requires registering it at organization scope and granting those repositories access. See [GitHub's runner access guidance](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/manage-access).

## Build, bootstrap, and version the image

The [Build CI image workflow](../.github/workflows/build-ci-image.yml) runs on changes anywhere under `build/ci/` or in its workflow file. Pull requests build the image without publishing it. Pushes publish an immutable `sha-<full-commit-sha>` tag for both `linux/amd64` and `linux/arm64`; the default branch also publishes `latest`. The main CI workflow uses the manually promoted `v1` tag, not `latest` or a guessed commit SHA.

The first image must exist in GHCR before the main CI workflow can start. After merging these files to `master`:

1. Wait for the automatic Build CI image run to publish its SHA tag.
2. In GitHub Actions, run **Build CI image** manually on `master`, leaving `image_version` as `v1`. This publishes the image under the tag consumed by CI.
3. Confirm the GHCR package grants this repository's Actions token permission to read it. The build workflow uses `GITHUB_TOKEN` with `packages: write`; the main CI job uses `GITHUB_TOKEN` with `packages: read`.
4. Register the self-hosted runner on the Linux VM and ensure its service account can access that VM's local Docker Engine as described above.
5. Run **CI** manually once, then rely on its normal triggers.

For a normal CI image update, changing a file under `build/ci/` automatically builds and publishes a new SHA tag, but does not move `v1`. After that build succeeds, run **Build CI image** manually with `image_version` set to `v1`; that run rebuilds the current Dockerfile and publishes the version tag. The manual build does not replace the SHA tag from the push. This keeps application CI on a known image version while the image is being built.

To introduce a new major CI image version, dispatch the build workflow with `image_version` set to (for example) `v2`. After the run publishes it, update the `container.image` tag in `ci.yml` to `v2` and run CI manually. The SHA tags preserve the exact image associated with each build.

## What runs in CI

The existing app workflow installs dependencies with `python -m venv`, `python -m pip install --upgrade pip`, and `python -m pip install -r requirements.txt`, then runs `zip -r` to build its deployment archive. The CI job reuses those commands, then runs `python -m pip check` and `python -m compileall` over the app's Python files. The repository currently has no automated test command for this app, so the workflow does not claim to run unit tests. The added infrastructure tools are available in the image; this does not add validation jobs for every Ansible, Terraform, Packer, or Kubernetes project yet.
