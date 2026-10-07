# Continuous integration

The repository is a collection of homelab configurations and standalone projects, not one application with a root build. The new CI job follows the existing `master_bitcoincountdown.yml` workflow for `Project/ExchangeLiquidityCountdown`: it installs that project's `requirements.txt`, builds the same ZIP deployment archive in `/tmp`, checks installed dependency consistency with `pip check`, and compiles its Python files. There is currently no automated unit test suite or configured linter for this project.

The main CI workflow runs for changes to `Project/ExchangeLiquidityCountdown/**` on `master`, same-repository pull requests targeting `master`, and manual dispatch. Fork pull requests are skipped so untrusted code does not run on the persistent self-hosted runner. The existing Azure build and deployment workflow remains separate.

## Self-hosted runner and Docker

The main CI job expects a self-hosted Linux runner with the labels `self-hosted` and `linux`. Install the GitHub Actions runner and Docker Engine on your Linux VM. The runner starts the job container through that VM's Docker Engine, so the runner service account must be able to run Docker commands without `sudo` (for a standard rootful Docker installation, this usually means adding that account to the `docker` group).

The development workstation does not need Docker. On the runner VM, keep Docker Engine running and leave the CLI pointed at its local daemon (`unix:///var/run/docker.sock` by default). No Docker API port needs to be exposed to the network.

Keep the GitHub Actions runner software current. The workflow uses current Node.js 24 actions, which require runner version 2.327.1 or newer.

The job runs inside a custom image from GHCR. The Dockerfile is [build/ci/Dockerfile](../build/ci/Dockerfile); the package is `ghcr.io/iaingblack/homelab-ci`. It contains Python 3.12, Bash, Git, `zip`, OpenSSH client tools, Ansible Core 2.21.5, `ansible-lint` 26.9.0, `yamllint` 1.38.0, Terraform 1.13.0 managed by `tfenv`, Packer 1.16.1, Task 3.53.1, `kubectl` 1.37.1, and Helm 3.22.0. The Terraform pin matches the repository's Terraform Taskfiles. Ansible collections are not bundled; install the collections each playbook needs with `ansible-galaxy`. The GitHub Actions runner is installed on the VM, and that VM's Docker Engine starts the job container.

The image is a focused set of command-line tools for the repository's Python, Ansible, Terraform, Packer, Taskfile, and Kubernetes projects. It does not include cloud provider CLIs or a Docker daemon; add cloud authentication and Docker socket access only to workflows that need them.

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
