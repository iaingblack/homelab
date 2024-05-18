# wget https://raw.githubusercontent.com/iaingblack/Dockerfiles/master/CentOS7-Docker-Install-Only.sh && chmod +x CentOS7-Docker-Install-Only.sh && ./CentOS7-Docker-Install-Only.sh
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
