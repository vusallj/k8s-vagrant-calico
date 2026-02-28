# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Static IPs for Kubernetes cluster (safe VirtualBox subnet)
MASTER_IP = "192.168.56.200"
NODE01_IP = "192.168.56.201"
NODE02_IP = "192.168.56.202"

NUM_WORKER_NODES = 2

# Helper: read VirtualBox machine ID
def get_machine_id(vm_name)
  machine_id_filepath = ".vagrant/machines/#{vm_name}/virtualbox/id"
  File.exist?(machine_id_filepath) ? File.read(machine_id_filepath) : nil
end

# Helper: check if all nodes are up
def all_nodes_up()
  return false if get_machine_id("controlplane").nil?
  return false if get_machine_id("node01").nil?
  return false if get_machine_id("node02").nil?
  true
end

# DNS + /etc/hosts provisioning
def setup_dns(node)
  node.vm.provision "setup-hosts", type: "shell", path: "ubuntu/vagrant/setup-hosts.sh" do |s|
    s.args = ["192.168.56", "NAT", NUM_WORKER_NODES, 200, 201]
  end
  node.vm.provision "setup-dns", type: "shell", path: "ubuntu/update-dns.sh"
end

# Common provisioning for all nodes
def provision_kubernetes_node(node)
  setup_dns node
  node.vm.provision "setup-ssh", type: "shell", path: "ubuntu/ssh.sh"
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.boot_timeout = 900
  config.vm.box_check_update = false

  #
  # CONTROL PLANE NODE
  #
  config.vm.define "controlplane" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "controlplane"
      vb.memory = 2048
      vb.cpus = 2
    end

    node.vm.hostname = "controlplane"
    node.vm.network :private_network, ip: MASTER_IP
    node.vm.network "forwarded_port", guest: 22, host: 2710

    provision_kubernetes_node node

    node.vm.provision "file", source: "./ubuntu/tmux.conf", destination: "$HOME/.tmux.conf"
    node.vm.provision "file", source: "./ubuntu/vimrc", destination: "$HOME/.vimrc"
  end

  #
  # WORKER NODE 01
  #
  config.vm.define "node01" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "node01"
      vb.memory = 1024
      vb.cpus = 1
    end

    node.vm.hostname = "node01"
    node.vm.network :private_network, ip: NODE01_IP
    node.vm.network "forwarded_port", guest: 22, host: 2721

    provision_kubernetes_node node
  end

  #
  # WORKER NODE 02
  #
  config.vm.define "node02" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name = "node02"
      vb.memory = 1024
      vb.cpus = 1
    end

    node.vm.hostname = "node02"
    node.vm.network :private_network, ip: NODE02_IP
    node.vm.network "forwarded_port", guest: 22, host: 2722

    provision_kubernetes_node node
  end
end
