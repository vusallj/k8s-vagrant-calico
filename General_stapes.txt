1. Install VirtualBox
VirtualBox provides the virtualization layer that runs the VMs. Without it, Vagrant cannot create the machines.

Users download it from the official site and install it normally.

2. Install Vagrant
Vagrant automates VM creation, provisioning, and SSH access. It reads your Vagrantfile and builds the cluster.

Users install it from the official HashiCorp site.

3. Clone your repository
This gives them your Vagrantfile and provisioning scripts.

4. Run vagrant up
This is the core step. It:

- creates the controlplane VM
- creates node01 and node02
- installs containerd
- installs kubeadm, kubelet, kubectl
- configures networking
- prepares the OS for Kubernetes

After this step, all three VMs are ready for kubeadm.

5. SSH into the controlplane
Users connect to the master node to initialize Kubernetes.

6. Run kubeadm init
This creates the Kubernetes control plane.

7. Configure kubectl
This allows the user to run kubectl commands from inside the controlplane VM.

8. Install Calico CNI
This sets up pod networking and allows nodes to become Ready.

9. Generate the join command
This produces the token and hash needed for workers to join the cluster.

10. SSH into node01 and node02 and run the join command
This connects the workers to the controlplane.

11. Verify the cluster
Users run kubectl get nodes to confirm everything is Ready.
