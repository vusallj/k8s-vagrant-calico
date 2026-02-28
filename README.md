# k8s-vagrant-calico
Configuration of k8s cluster with vagrant/virtualbox

Full flow for users of your repo
1. Install VirtualBox
Download from: https://www.virtualbox.org/wiki/Downloads

2. Install Vagrant
Download from: https://developer.hashicorp.com/vagrant/downloads

3. Clone repo
```bash
git clone https://github.com/vusallj/k8s-vagrant-calico.git
cd k8s-vagrant-calico
```
4. Start the VMs
```bash
vagrant up
```
This runs all provisioning scripts on all nodes.
- creates the controlplane VM
- creates node01 and node02
- installs containerd
- installs kubeadm, kubelet, kubectl
- configures networking
- prepares the OS for Kubernetes

  
5. SSH into the controlplane Connect to the master node to initialize Kubernetes.
```bash
vagrant ssh controlplane
```
6. Initialize Kubernetes (controlplane only)
```bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.200 \
  --pod-network-cidr=192.168.0.0/16
```
7. Configure kubectl (controlplane only). This allows to run kubectl commands from inside the controlplane VM.
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
8. Install Calico CNI (controlplane only). This sets up pod networking and allows nodes to become Ready.
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
```
9 Check pods status. Calico CNI pods takes sometime to be fully run. 
```bash
kubectl get pods -n kube-system
```
        
10. Generate join command (controlplane only). This produces the token and hash needed for workers to join the cluster.
```bash
sudo kubeadm token create --print-join-command
```
11. SSH into node01 and node02 and run the join command This connects the workers to the controlplane.
```bash
vagrant ssh node01
sudo kubeadm join <command>
```
``` bash
vagrant ssh node02
sudo kubeadm join <command>
```
12. Verify (wait for few minutes untill calico pods start working)
```bash
kubectl get nodes -o wide
```

13. To run VMs
```bash
vagrant up
```
13 To make safe stup
```bash
Vagrant halt
```

