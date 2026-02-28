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
( RUN BELOW COMMANS ON ALL NODES)

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

8. Install containerd 
```bash
sudo apt-get update
sudo apt-get install -y containerd

```

9. Generate config
```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
```

9. Enable systemd cgroup driver
```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```

10. Restart
```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```

11. Install k8s repo
```bash
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo mkdir -p /etc/apt/keyrings
```

12. Add key
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

13. add the repo
```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
```

14. Install kubeadm, kubectl, kubelet
```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


15. Initialize controlplane (ONLY ON CONTROLPLANE)
```bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.10 \
  --pod-network-cidr=192.168.0.0/16
```

16. Konfigure kubectl
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

17. Run on controlplane to get join commands for worker nodes. **(Later run printed command on each nodes)**
```bash
kubeadm token create --print-join-command
```

18. Install Calico CNI on controlplane
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```



19. Check pods status. Calico CNI pods takes sometime to be fully run. 
```bash
kubectl get pods -n kube-system
```

20. Test if nodes got IP and your are good to go
```bash
kubectl get nodes -o wide
```      

21. To run VMs
```bash
vagrant up
```
22. To make safe stup
```bash
Vagrant halt
```

