# k8s-vagrant-calico
Configuration of k8s cluster with vagrant/virtualbox

Full flow for users of your repo
1. Install VirtualBox
Download from: https://www.virtualbox.org/wiki/Downloads

2. Install Vagrant
Download from: https://developer.hashicorp.com/vagrant/downloads

3. Clone your repo
bash
git clone https://github.com/<your-username>/k8s-vagrant-calico.git
cd k8s-vagrant-calico
4. Start the VMs
bash
vagrant up
This runs all provisioning scripts on all nodes.

5. SSH into controlplane
bash
vagrant ssh controlplane
6. Initialize Kubernetes (controlplane only)
bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.200 \
  --pod-network-cidr=192.168.0.0/16
7. Configure kubectl (controlplane only)
bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
8. Install Calico (controlplane only)
bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
9. Generate join command (controlplane only)
bash
sudo kubeadm token create --print-join-command
10. Join workers
bash
vagrant ssh node01
sudo kubeadm join <command>

vagrant ssh node02
sudo kubeadm join <command>
11. Verify
bash
kubectl get nodes -o wide
