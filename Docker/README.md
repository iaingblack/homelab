# Dockerfiles

My dockerfiles for apps

## LINUX

**REMOVE ALL CONTAINERS**

```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

**DELETE ALL IMAGES**
```bash
docker rmi $(docker images -q -a)
```

**KEEP A CONTAINER RUNNING TO INSPECT LATER**
```bash
docker run -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

## WINDOWS (POWERSHELL)

**REMOVE DANGLING IMAGES**
```bash
docker images --filter dangling=true -q | %{docker rmi -f $_}
```

**STOP ALL CONTAINERS**
```bash
docker ps -a -q | %{docker stop $_}
```

**REMOVE ALL CONTAINERS**
```bash
docker ps -a -q | %{docker rm -f $_}
```

**REMOVE ALL IMAGES (DANGEROUS!)**
```bash
docker images | %{docker rmi -f $_}
```

## MISC
**ADD A PROXY WHEN CREATING DOCKERFILES**
```bash
ENV http_proxy http://server:port
ENV https_proxy http://server:port
```

**FOLLOW LOGS ON A CONTAINER**
```bash
docker logs -f 878978547
```
