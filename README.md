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
( run below commands on each nodes)

5. Disable swapp
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

6.Load kernel modules
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

```
7. Apply systl settings
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

7. Install containerd
```bash
sudo apt-get update
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Use systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
```

8. Install kubeadm
```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
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
9. Check pods status. Calico CNI pods takes sometime to be fully run. 
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

