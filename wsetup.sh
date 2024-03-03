#!/bin/bash
#sudo ip=$(hostname -i |cut -c 11-14)
#sudo hostnamectl set-hostname k8s-worker-$ip
##### Disable Firewall
sudo ufw disable
##### Disable swap
sudo swapoff -a 
sudo sed -i '/swap/d' /etc/fstab
##### Update sysctl settings for Kubernetes networking
sudo cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
##### Install docker engine
{
  sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io
}
### Kubernetes Setup
{
 sudo  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
 sudo  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}
sudo apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
##### In case you are using LXC containers for Kubernetes nodes
{
 sudo  mknod /dev/kmsg c 1 11
  sudo echo '#!/bin/sh -e' >> /etc/rc.local
  sudo echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.local
  sudo chmod +x /etc/rc.local
}

