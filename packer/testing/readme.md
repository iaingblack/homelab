README

First install packer as a tap

brew tap hashicorp/tap
brew install hashicorp/tap/packer

Or a binary, download

https://developer.hashicorp.com/packer/install
cp packer /usr/local/packer


Build

```
packer init .
packer fmt .
packer build docker-ubuntu.pkr.hcl
```

Check

```
docker images

2bdccad8c8c3



```