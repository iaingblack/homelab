# Examples

## Install Tools

### Install just KIND
```bash
task install-kind
```

### Install just kubectl
```bash
task install-kubectl
```

### Install both tools
```bash
task install-tools
```

## Basic Workflow

### 1. Create cluster (creates config and cluster)
```bash
task setup
```

### 2. Create admin user and get token
```bash
task create-admin-user
```

### 3. Delete cluster and cleanup files
```bash
task cleanup
```

## Custom Cluster

### 1. Create cluster with custom name
```bash
task setup CLUSTER_NAME=my-test-cluster
```

### 2. Create admin user for the specific cluster
```bash
task create-admin-user CLUSTER_NAME=my-test-cluster
```

### 3. Delete the specific cluster
```bash
task delete-cluster CLUSTER_NAME=my-test-cluster
```

## Remote Access Workflow:

### 1. Create cluster with remote access (specify your host IP)
```bash
task setup-remote CLUSTER_NAME=dev-cluster HOST_IP=192.168.1.100 API_PORT=6443
```

### 2. Get connection info (shows endpoint and token)
```bash
task get-connection-info CLUSTER_NAME=dev-cluster
```

### 3. Delete the cluster
```bash
task delete-cluster CLUSTER_NAME=dev-cluster

## Individual Commands

### Create config file
```bash
task create-config CLUSTER_NAME=test-cluster

### Create cluster
```bash
task create-cluster CLUSTER_NAME=test-cluster
```

### Create admin user
```bash
task create-admin-user CLUSTER_NAME=test-cluster
```

### Delete cluster
```bash
task delete-cluster CLUSTER_NAME=test-cluster
```
