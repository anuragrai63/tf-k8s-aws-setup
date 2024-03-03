# tf-k8s-aws-setup
Kubernetes Setup with terraform 
After Successful terraform apply-

# Cluster join command on Master
kubeadm token create --print-join-command
# To be able to run kubectl commands as non-root user
# If you want to be able to run kubectl commands as non-root user, then as a non-root user perform these

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# On Kworker
# Join the cluster
# Use the output from kubeadm token create command in previous step from the master server and run here.

# Verifying the cluster (On kmaster)
# Get Nodes status
kubectl get nodes
# Get component status
kubectl get cs
