# k8s-vagrant-calico
Configuration of k8s cluster with vagrant/virtualbox

Full flow for users of your repo
1. Install VirtualBox
Download from: https://www.virtualbox.org/wiki/Downloads

2. Install Vagrant
Download from: https://developer.hashicorp.com/vagrant/downloads

3. Clone your repo
```bash
git clone https://github.com/vusallj/k8s-vagrant-calico.git
cd k8s-vagrant-calico
```
5. Start the VMs
```bash
vagrant up
```
This runs all provisioning scripts on all nodes.

7. SSH into controlplane
```bash
vagrant ssh controlplane
```
8. Initialize Kubernetes (controlplane only)
```bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.200 \
  --pod-network-cidr=192.168.0.0/16
```
9. Configure kubectl (controlplane only)
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
10. Install Calico (controlplane only)
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
```
11. Generate join command (controlplane only)
```bash
sudo kubeadm token create --print-join-command
```
12. Join workers
```bash
vagrant ssh node01
sudo kubeadm join <command>
```
``` bash
vagrant ssh node02
sudo kubeadm join <command>
```
11. Verify (wait for few minutes untill calico pods start working"
```bash
kubectl get nodes -o wide
```

12. To run VMs
```bash
vagrant up
```
13 To make safe stup
```bash
Vagrant halt
```

