# GitHub Actions Runner Controller on `hetzner-arc-k8s`

This guide installs a small Kubernetes cluster with **KIND** on a Hetzner-hosted Ubuntu server, installs **GitHub Actions Runner Controller (ARC)**, and registers an **organization-level runner scale set**.

Replace the example values and export these two variables before connecting to the server:

```bash
export HETZNER_PUBLIC_IP="<server-public-ip>"
export GITHUB_ORG="<github-organization>"
```

After connecting, export the same values in the VM shell before running the configuration-generation commands. SSH does not pass local shell variables to the remote session automatically.

- **Server name:** `hetzner-arc-k8s`
- **Public IP:** `$HETZNER_PUBLIC_IP`
- **GitHub organization:** `https://github.com/$GITHUB_ORG`
- **Runner scale set name:** `hetzner-arc-k8s`

The end result is:

```text
GitHub organization: $GITHUB_ORG
          |
          | outbound HTTPS connection from ARC/runners
          v
Hetzner server: hetzner-arc-k8s
Public IP: $HETZNER_PUBLIC_IP
          |
          v
        KIND
          |
          v
Actions Runner Controller
          |
          v
Ephemeral GitHub Actions runner pods
```

Each workflow job can target the scale set with:

```yaml
runs-on: hetzner-arc-k8s
```

The runner pods are created as jobs arrive and removed afterwards.

> **Important:** GitHub does not need inbound access to the runner pods. ARC and the runners initiate outbound connections to GitHub. The public IP is mainly relevant if you want to administer the Kubernetes API remotely.

---

## 1. Assumptions

This guide assumes:

- Ubuntu 24.04 or similar
- x86-64 / AMD64 server
- root or sudo access
- outbound Internet access
- DNS is optional
- GitHub Actions is enabled for the organization set in `GITHUB_ORG`

Log into the server:

```bash
ssh root@"$HETZNER_PUBLIC_IP"
```

Set the hostname:

```bash
hostnamectl set-hostname hetzner-arc-k8s
```

Check it:

```bash
hostnamectl
```

---

## 2. Security before exposing Kubernetes

If you intend to administer the KIND Kubernetes API remotely, this guide exposes the API server on:

```text
$HETZNER_PUBLIC_IP:45001
```

Do **not** leave that port open to the whole Internet.

Ideally restrict it at the Hetzner firewall to your management IP.

For example, allow:

```text
TCP 22     from your management IP
TCP 45001  from your management IP
```

You do **not** need inbound GitHub traffic to the server for ARC.

If you will only administer Kubernetes locally over SSH, you can instead bind the KIND API to `127.0.0.1` and avoid exposing port `45001` entirely.

---

## 3. Install Docker, Helm and kubectl

Update the machine:

```bash
apt update
apt upgrade -y
```

Install some basic utilities:

```bash
apt install -y curl ca-certificates jq git
```

For a simple lab-style installation, install Docker, Helm and kubectl:

```bash
snap install docker --classic
snap install helm --classic
snap install kubectl --classic
```

Check them:

```bash
docker --version
helm version
kubectl version --client
```

Test Docker:

```bash
docker run --rm hello-world
```

---

## 4. Install KIND

At the time this guide was written, KIND `v0.33.0` was the current stable release.

Install the AMD64 binary:

```bash
curl -Lo ./kind \
  https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64

chmod +x ./kind

mv ./kind /usr/local/bin/kind
```

Check it:

```bash
kind version
```

For ARM64 instead, use:

```bash
curl -Lo ./kind \
  https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-arm64
```

Current KIND releases:

https://kind.sigs.k8s.io/docs/user/quick-start/

---

## 5. Create the KIND cluster configuration

Create a working directory:

```bash
mkdir -p /opt/hetzner-arc-k8s
cd /opt/hetzner-arc-k8s
```

Generate `kind.yaml` using the exported `HETZNER_PUBLIC_IP` variable:

```text
kind.yaml
```

```bash
cat > kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: hetzner-arc-k8s

networking:
  ipFamily: ipv4
  apiServerAddress: "${HETZNER_PUBLIC_IP}"
  apiServerPort: 45001
EOF
```

Create the cluster:

```bash
kind create cluster \
  --name hetzner-arc-k8s \
  --config kind.yaml
```

Confirm the cluster exists:

```bash
kind get clusters
```

Expected:

```text
hetzner-arc-k8s
```

Check Kubernetes:

```bash
kubectl cluster-info
```

and:

```bash
kubectl get nodes
```

You should see the KIND control-plane node in `Ready` state.

---

## 6. Check the kubeconfig

KIND automatically configures your local `kubectl` context.

Check:

```bash
kubectl config current-context
```

Expected:

```text
kind-hetzner-arc-k8s
```

You can also inspect:

```bash
kubectl config view --minify
```

If you want to manage the cluster from another machine, copy the relevant kubeconfig securely and make sure TCP `45001` is only reachable from that management machine.

---

# 7. Create a GitHub Personal Access Token

ARC needs credentials so it can register and manage ephemeral runners in the organization set in `GITHUB_ORG`.

GitHub supports:

- a GitHub App
- a fine-grained Personal Access Token
- a classic Personal Access Token

For production, GitHub recommends using a **GitHub App** for repository- or organization-level ARC deployments.

For this initial setup, a PAT is simpler.

---

## Option A — Fine-grained PAT

Open GitHub and go to:

```text
Profile picture
→ Settings
→ Developer settings
→ Personal access tokens
→ Fine-grained tokens
→ Generate new token
```

Configure it approximately as follows.

### Token name

```text
hetzner-arc-k8s
```

### Resource owner

Select the organization identified by the `GITHUB_ORG` variable.

### Expiration

Choose an appropriate short-lived expiration rather than creating a permanent credential.

### Repository access

Because this is an organization-level runner scale set, select the repository access appropriate to the repositories you intend the runner group to serve.

### Organization permissions

Set:

```text
Administration       Read
Self-hosted runners  Read and write
```

Generate the token and copy it immediately.

It will look something like:

```text
github_pat_...
```

Do not put the token into Git, shell history, `values.yaml`, or this documentation.

GitHub documentation:

https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/authenticate-to-the-api

---

## Option B — Classic PAT

If you prefer a classic PAT:

```text
Profile picture
→ Settings
→ Developer settings
→ Personal access tokens
→ Tokens (classic)
→ Generate new token (classic)
```

Give it a name such as:

```text
hetzner-arc-k8s
```

For an organization-level ARC runner, enable:

```text
admin:org
```

If the setup also requires access to private repositories, you may additionally need the appropriate `repo` access.

Copy the token when GitHub displays it.

---

# 8. Create a GitHub runner group

This step is recommended because it lets you control which repositories in the organization can use this runner infrastructure.

In the organization set in `GITHUB_ORG`, open **Settings → Actions → Runner groups**.

To print the direct link from your setup shell, run:

```bash
printf 'https://github.com/organizations/%s/settings/actions/runner-groups\n' "$GITHUB_ORG"
```

Create a runner group called:

```text
hetzner-arc-k8s
```

For initial testing you can allow all repositories, but for a real environment it is better to choose:

```text
Selected repositories
```

and explicitly grant access to only the repositories that should be able to run workloads on this cluster.

This matters because GitHub Actions jobs running here can potentially access network resources reachable from the Hetzner server.

---

# 9. Install the ARC controller

ARC has two main parts:

```text
Runner Scale Set Controller
          |
          +---- Runner Scale Set
          +---- Runner Scale Set
          +---- Runner Scale Set
```

You normally install the controller once per Kubernetes cluster.

Create the controller namespace:

```bash
kubectl create namespace arc-systems
```

Install the controller:

```bash
helm install arc \
  --namespace arc-systems \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

Check Helm:

```bash
helm list -A
```

Check the controller pods:

```bash
kubectl get pods -n arc-systems
```

Wait until the controller is `Running`.

You can also watch it:

```bash
kubectl get pods -n arc-systems -w
```

---

# 10. Create the runner namespace

Keep runner workloads separate from the controller:

```bash
kubectl create namespace arc-runners
```

This separation is recommended because the runner pods execute repository-controlled workflow code.

---

# 11. Store the PAT as a Kubernetes secret

Set the PAT temporarily in your shell:

```bash
read -s GITHUB_PAT
```

Paste the PAT and press Enter.

Nothing will be echoed to the terminal.

Create a Kubernetes secret:

```bash
kubectl create secret generic github-arc-auth \
  --namespace arc-runners \
  --from-literal=github_token="${GITHUB_PAT}"
```

Immediately clear it from the shell variable:

```bash
unset GITHUB_PAT
```

Confirm the secret exists:

```bash
kubectl get secret github-arc-auth -n arc-runners
```

Do not run commands that print the secret contents.

---

# 12. Create the ARC runner scale set values

Create:

```text
/opt/hetzner-arc-k8s/arc-values.yaml
```

with the organization URL populated from `GITHUB_ORG`:

```bash
cat > /opt/hetzner-arc-k8s/arc-values.yaml <<EOF
githubConfigUrl: "https://github.com/${GITHUB_ORG}"

githubConfigSecret: "github-arc-auth"

runnerGroup: "hetzner-arc-k8s"

runnerScaleSetName: "hetzner-arc-k8s"

minRunners: 0
maxRunners: 5

containerMode:
  type: dind
EOF
```

A few important points:

### `githubConfigUrl`

This resolves to the organization URL:

```text
https://github.com/$GITHUB_ORG
```

Because this is organization-scoped, the runner scale set is available to repositories permitted by the runner group rather than being bound to one repository.

### `runnerGroup`

This must match the organization runner group created earlier:

```text
hetzner-arc-k8s
```

### `runnerScaleSetName`

This becomes the value repositories use in:

```yaml
runs-on: hetzner-arc-k8s
```

### `minRunners`

```yaml
minRunners: 0
```

means you do not keep idle runner pods alive.

### `maxRunners`

```yaml
maxRunners: 5
```

means the cluster will create at most five runner pods at once.

Adjust this based on the CPU and RAM available on the Hetzner machine.

### `containerMode`

```yaml
containerMode:
  type: dind
```

enables Docker-in-Docker support.

This is useful when workflows use:

```yaml
container:
  image: ...
```

or need Docker during a job.

Be aware that DinD generally involves privileged containers. Treat repositories allowed to use this runner group as trusted.

---

# 13. Install the organization runner scale set

Install it:

```bash
helm install hetzner-arc-k8s \
  --namespace arc-runners \
  -f /opt/hetzner-arc-k8s/arc-values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

Check Helm:

```bash
helm list -A
```

You should now see both the ARC controller and the runner scale set.

Check the runner namespace:

```bash
kubectl get pods -n arc-runners
```

With:

```yaml
minRunners: 0
```

you may not see a runner pod sitting idle. That is expected.

ARC should create runners when matching GitHub Actions jobs are queued.

---

# 14. Check the runner in GitHub

In the organization set in `GITHUB_ORG`, open **Settings → Actions → Runners**.

To print the direct link from your setup shell, run:

```bash
printf 'https://github.com/organizations/%s/settings/actions/runners\n' "$GITHUB_ORG"
```

You should see the scale set:

```text
hetzner-arc-k8s
```

Also check:

```text
Organization
→ Settings
→ Actions
→ Runner groups
→ hetzner-arc-k8s
```

Confirm that the repositories you want to test are allowed to use the group.

---

# 15. Test from an existing repository

In a repository allowed to use the runner group, create:

```text
.github/workflows/test-arc.yml
```

with:

```yaml
name: Test hetzner ARC

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: hetzner-arc-k8s

    steps:
      - name: Runner information
        run: |
          echo "Running on ARC"
          uname -a
          id
```

Commit and push the workflow.

Open:

```text
Repository
→ Actions
→ Test hetzner ARC
→ Run workflow
```

While the workflow is queued, watch Kubernetes:

```bash
kubectl get pods -n arc-runners -w
```

You should see an ephemeral runner pod appear.

The rough lifecycle is:

```text
workflow queued
      |
      v
ARC sees demand
      |
      v
runner pod created
      |
      v
runner registers with $GITHUB_ORG
      |
      v
job assigned
      |
      v
job completes
      |
      v
runner deregisters
      |
      v
pod deleted
```

---

# 16. Test a custom job container

To confirm the runner can execute a job inside a container, use:

```yaml
name: Test ARC Container

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: hetzner-arc-k8s

    container:
      image: debian:stable-slim

    steps:
      - name: Confirm container
        run: |
          cat /etc/os-release
          echo "This step is running inside the Debian job container."
```

Run the workflow again.

The architecture for that job is roughly:

```text
KIND Kubernetes
      |
      v
ephemeral ARC runner pod
      |
      v
Docker-in-Docker
      |
      v
Debian job container
      |
      v
workflow steps
```

---

# 17. Test Docker inside the runner

If the job itself needs Docker, try:

```yaml
name: Test ARC Docker

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: hetzner-arc-k8s

    steps:
      - name: Docker information
        run: docker info

      - name: Run a container
        run: docker run --rm alpine:latest echo "Docker works"
```

This is one reason this setup uses:

```yaml
containerMode:
  type: dind
```

---

# 18. Using a custom CI image

Once ARC is working, a repository can use a centrally maintained CI image.

For example:

```yaml
jobs:
  build:
    runs-on: hetzner-arc-k8s

    container:
      image: ghcr.io/<GITHUB_ORG>/ci-tools:1.0.0

    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: ./build.sh

      - name: Test
        run: ./test.sh
```

This gives you:

```text
GitHub workflow
      |
      v
hetzner-arc-k8s runner scale set
      |
      v
ephemeral runner pod
      |
      v
custom CI image
```

The Kubernetes runner is ephemeral, and the job's toolchain is controlled by the container image.

Replace `<GITHUB_ORG>` in the example image name with the value of the `GITHUB_ORG` variable before using the workflow.

---

# 19. Useful troubleshooting commands

## Check everything

```bash
helm list -A
```

```bash
kubectl get pods -A
```

```bash
kubectl get all -n arc-systems
```

```bash
kubectl get all -n arc-runners
```

---

## Controller logs

Find the controller:

```bash
kubectl get pods -n arc-systems
```

Then:

```bash
kubectl logs \
  -n arc-systems \
  <controller-pod-name>
```

Or use a label query if appropriate for the installed chart.

---

## Runner scale-set resources

```bash
kubectl get autoscalingrunnersets -A
```

```bash
kubectl get ephemeralrunnersets -A
```

```bash
kubectl get ephemeralrunners -A
```

---

## Describe a failing pod

```bash
kubectl describe pod \
  -n arc-runners \
  <pod-name>
```

---

## View runner pod logs

```bash
kubectl logs \
  -n arc-runners \
  <pod-name>
```

---

# 20. Updating ARC

Check the installed charts:

```bash
helm list -A
```

Update the controller:

```bash
helm upgrade arc \
  --namespace arc-systems \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

Update the runner scale set:

```bash
helm upgrade hetzner-arc-k8s \
  --namespace arc-runners \
  -f /opt/hetzner-arc-k8s/arc-values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

Always review ARC release notes and chart changes before upgrading production infrastructure.

---

# 21. Scaling

The initial configuration is:

```yaml
minRunners: 0
maxRunners: 5
```

For a larger host you might use:

```yaml
minRunners: 0
maxRunners: 10
```

If you want some runners pre-warmed:

```yaml
minRunners: 1
maxRunners: 10
```

Remember that this is a single physical/virtual host running KIND, so adding more pods does not create additional underlying CPU or RAM.

For real horizontal capacity you would eventually move from KIND on one VM to a proper multi-node Kubernetes cluster.

---

# 22. Recommended production improvement: GitHub App

A PAT is convenient for initial setup, but for an organization-level ARC deployment GitHub recommends authenticating with a GitHub App.

At organization scope the GitHub App should have:

```text
Organization permissions
└── Self-hosted runners: Read and write
```

and appropriate metadata access.

That removes the dependency on a personal user credential and is preferable for long-lived infrastructure.

Current GitHub documentation:

https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/authenticate-to-the-api

---

# 23. Recommended organization layout

Once the basic setup works, consider multiple runner groups or scale sets rather than putting every workload into one pool.

For example:

```text
$GITHUB_ORG
|
+-- Runner Group: general
|      |
|      +-- arc-general
|
+-- Runner Group: internal
|      |
|      +-- arc-internal
|
+-- Runner Group: production
       |
       +-- arc-production
```

That lets you control which repositories can access different levels of infrastructure.

For this initial install, everything is intentionally kept simple:

```text
Runner Group:
  hetzner-arc-k8s

Runner Scale Set:
  hetzner-arc-k8s
```

---

# 24. Removing the installation

Remove the runner scale set:

```bash
helm uninstall hetzner-arc-k8s \
  --namespace arc-runners
```

Remove the controller:

```bash
helm uninstall arc \
  --namespace arc-systems
```

Delete the namespaces:

```bash
kubectl delete namespace arc-runners
kubectl delete namespace arc-systems
```

Delete the KIND cluster:

```bash
kind delete cluster \
  --name hetzner-arc-k8s
```

---

# 25. Final configuration summary

```text
Host
----
Name:       hetzner-arc-k8s
Public IP:  $HETZNER_PUBLIC_IP

Kubernetes
----------
Distribution: KIND
Cluster:      hetzner-arc-k8s
API port:     45001

GitHub
------
Organization:
https://github.com/$GITHUB_ORG

Runner group:
hetzner-arc-k8s

Runner scale set:
hetzner-arc-k8s

Workflow selector:
runs-on: hetzner-arc-k8s

ARC controller namespace:
arc-systems

Runner namespace:
arc-runners

Authentication:
GitHub PAT stored as Kubernetes secret github-arc-auth

Runner mode:
Ephemeral

Container support:
Docker-in-Docker
```

A repository can therefore use the organization runner with:

```yaml
jobs:
  build:
    runs-on: hetzner-arc-k8s

    container:
      image: debian:stable-slim

    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello from hetzner-arc-k8s"
```

---

## References

- GitHub Actions Runner Controller:
  https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller

- Authenticating ARC:
  https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/authenticate-to-the-api

- Deploying ARC runner scale sets:
  https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/deploy-runner-scale-sets

- Using ARC runners in workflows:
  https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/use-arc-in-a-workflow

- KIND:
  https://kind.sigs.k8s.io/docs/user/quick-start/
