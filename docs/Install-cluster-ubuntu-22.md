# Install Kubernetes Cluster using kubeadm
Follow this documentation to set up a Kubernetes cluster on __Ubuntu 22.04 LTS__. with Flannel Network

This documentation guides you in setting up a cluster with one master node and one worker node.

## Assumptions
|Role|FQDN|IP|OS|RAM|CPU|
|----|----|----|----|----|----|
|Master|master.example.com|x.x.x.x|Ubuntu 22.00|2G|2|
|Worker|worker.example.com|x.x.x.x|Ubuntu 22.00|1G|1|

##### Set Host Name respectively for Master & Worker.
sudo hostnamectl set-hostname master-node

## On both master and worker
##### Install docker and K8S
```
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
```
```
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

##### Prepare for Kubernetes Deployment
```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
```
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
```
```
sudo modprobe overlay
sudo modprobe br_netfilter
```
```
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```
```
sysctl --system
```
```
cat >>/etc/default/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"
EOF
```
```
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```
```
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
```

```
sudo systemctl daemon-reload && sudo systemctl restart docker
```
# On Master
## Initialize Cluster
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
##### To be able to run kubectl commands as non-root user
If you want to be able to run kubectl commands as non-root user, then as a non-root user perform these
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

##### Deploy Pod Network to cluster 
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```
# Note:- If you use custom podCIDR (not 10.244.0.0/16) you first need to download the above manifest and modify the network to match your one.

##### Cluster join command
```
kubeadm token create --print-join-command
```
## On worker
sudo systemctl stop apparmor && sudo systemctl disable apparmor
sudo systemctl restart containerd.service

##### Join the cluster
Use the output from __kubeadm token create__ command in previous step from the master server and run here.

## Verifying the cluster (On kmaster)
##### Get Nodes status
```
kubectl get nodes
```
##### Get component status
```
kubectl get cs
```
##### Get Pod status
```
kubectl get pods -A
```

