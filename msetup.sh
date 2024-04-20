####https://phoenixnap.com/kb/install-kubernetes-on-ubuntu
#!/bin/bash
###############Tested Steps:-
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

##############Install Kubernetes###########################
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

##########################Prepare for Kubernetes Deployment#################################
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

sudo hostnamectl set-hostname master-node

cat >>/etc/default/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"
EOF

sudo systemctl daemon-reload && sudo systemctl restart kubelet

cat >>/etc/docker/daemon.json<<EOF
{
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
   },
       "storage-driver": "overlay2"
       }
EOF

sudo systemctl daemon-reload && sudo systemctl restart docker

#sudo kubeadm init --control-plane-endpoint=master-node --upload-certs
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

############Deploy Pod Network to Cluster#############################
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
#kubectl taint nodes --all node-role.kubernetes.io/control-plane-


echo " Master Node Setup"


