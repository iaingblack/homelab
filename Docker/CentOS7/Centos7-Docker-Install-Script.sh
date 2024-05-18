#QUICKSTART
#---------
#wget https://github.com/iaingblack/Dockerfiles/blob/master/Centos7-Docker-Install-Script.sh
#chmod +x Centos7-Docker-Install-Script.sh
#./Centos7-Docker-Install-Script.sh

yum update -y

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install docker-engine -y
systemctl enable docker
systemctl start docker

curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine

docker-compose --version
docker-machine version

yum install git nano -y

systemctl stop firewalld
systemctl disable firewalld

#End the basic install if this file is run
exit 0

git clone https://github.com/iaingblack/Dockerfiles.git
cd Dockerfiles
git pull

#IF THERE IS A PROXY, DO THIS - https://docs.docker.com/engine/admin/systemd/#http-proxy
mkdir /etc/systemd/system/docker.service.d
nano /etc/systemd/system/docker.service.d/http-proxy.conf

[Service]
Environment="HTTP_PROXY=http://myproxy:80"

systemctl daemon-reload
systemctl show --property=Environment docker
systemctl restart docker

#To run on port 4243 so it is accessible by external systems (ie Foreman and docker plugin), amend this 
# http://stackoverflow.com/questions/26166550/set-docker-opts-in-centos
nano /usr/lib/systemd/system/docker.service
  ExecStart=/usr/bin/dockerd
to
  ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243
or
  ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock
  
systemctl daemon-reload
systemctl restart docker
chmod 777 /var/run/docker.sock

Then add a user;

useradd dockeruser
usermod -aG docker your_username
passwd dockeruser
systemctl restart docker

#May need to add these packages - #https://bugzilla.redhat.com/show_bug.cgi?id=1317011
yum install -y docker-engine-selinux foreman-selinux

#To add a shared folder in VMWare Workstation do this
mount -t vmhgfs .host:/ /home/iain/Documents/share/

#EPEL resource
https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
