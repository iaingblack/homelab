How to setup and use Dockur on MicroK8S

```bash
sudo apt install docker.io -y
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap install microk8s --classic
sudo snap alias microk8s.kubectl kubectl
sudo usermod -a -G microk8s iain
newgrp microk8s
```

Check KVM works
```bash
sudo apt update && sudo apt install cpu-checker -y   # if not installed
sudo kvm-ok
```


We need to enable host level storage (though not sure we use as the ISO is in the image now)
```bash
microk8s enable storage
microk8s stop; microk8s start
```

Enable the registry on microk8s and make it 50GB
```bash
microk8s enable registry:size=50Gi
```

Then 
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["localhost:32000", "127.0.0.1:32000"]
}
EOF
sudo systemctl restart docker
```

Get K9S Setup to ease management
```bash
cd $HOME
mkdir .kube
sudo chown -R iain ~/.kube
cd .kube
microk8s config > config
wget https://github.com/derailed/k9s/releases/download/v0.50.16/k9s_linux_amd64.deb
dpkg -i k9s_linux_amd64.deb
```

Pull image locally
```bash
docker pull docker.io/dockurr/windows
```

Copy your windows iso to a windows folder (this example is 2025), make sure called boot.iso
```bash
mkdir -p dockur/windows2025
cd dockur/windows2025
```

Then make a new image with the iso file baked in, make this Dockerfile
```bash
FROM docker.io/dockurr/windows
COPY boot.iso /boot.iso
```

Create the image, push to our local registrym and check it is available in teh catalog
```bash
docker build . -t localhost:32000/dockur-windows:2025
docker push localhost:32000/dockur-windows:2025
curl http://localhost:32000/v2/_catalog
```

Enable MetalLB so we can get a dedicated IP on our LAN
```bash
microk8s enable metallb:192.168.1.190-192.168.1.195
```

Make this `deployment.yaml` file as our spec. It creates everything required
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: dockur
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: windows-2025
  namespace: dockur
  labels:
    name: windows
spec:
  replicas: 1
  selector:
    matchLabels:
      app: windows
  template:
    metadata:
      labels:
        app: windows
    spec:
      containers:
      - name: windows
        image: localhost:32000/dockur-windows:2025
        env:
        - name: DISK_SIZE
          value: "64G"
        - name: VERSION
          value: "2025"
        # No VERSION env needed with mounted ISO
        resources:  # Add this for resource limits
          requests:
            cpu: "4"
            memory: "8Gi"
          limits:
            cpu: "8"
            memory: "16Gi"
        ports:
          - containerPort: 8006
            name: http
            protocol: TCP
          - containerPort: 3389
            name: rdp
            protocol: TCP
          - containerPort: 3389
            name: udp
            protocol: UDP
          - containerPort: 5900
            name: vnc
            protocol: TCP
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
          privileged: true
        volumeMounts:
        - mountPath: /storage
          name: storage
        - mountPath: /dev/kvm
          name: dev-kvm
        - mountPath: /dev/net/tun
          name: dev-tun
      terminationGracePeriodSeconds: 120
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: windows-pvc  # Created via storage addon
      - name: dev-kvm
        hostPath:
          path: /dev/kvm
      - name: dev-tun
        hostPath:
          path: /dev/net/tun
          type: CharDevice
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: windows-pvc
  namespace: dockur
spec:
  accessModes:
    - ReadWriteOnce          # Most common & usually works
  resources:
    requests:
      storage: 80Gi          # Make it bigger than DISK_SIZE (64G) + some overhead
---
apiVersion: v1
kind: Service
metadata:
  name: windows-lb
  namespace: dockur
spec:
  selector:
    app: windows               # matches your Deployment
  type: LoadBalancer
  ports:
    - name: web
      protocol: TCP
      port: 8006
      targetPort: 8006

    - name: rdp-tcp
      protocol: TCP
      port: 3389
      targetPort: 3389

    - name: rdp-udp           # optional — improves RDP smoothness
      protocol: UDP
      port: 3389
      targetPort: 3389   # same nodePort as TCP is OK!
```

Then deploy
```bash
microk8s kubectl apply -f deployment.yaml -n dockur
microk8s kubectl get pod -n dockur
microk8s kubectl get svc windows-lb -n dockur -w
```

Delete
```bash
microk8s kubectl delete -f deployment.yaml -n dockur
```

Check the external IP using K9S service view and then connect like http://192.168.1.190:8006 (note, Safari does not like this, use Chrome/Edge)