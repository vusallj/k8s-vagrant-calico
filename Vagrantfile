# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

MASTER_IP = "192.168.56.200"
NODE01_IP = "192.168.56.201"
NODE02_IP = "192.168.56.202"

NUM_WORKER_NODES = 2

def get_machine_id(vm_name)
  machine_id_filepath = ".vagrant/machines/#{vm_name}/virtualbox/id"
  File.exist?(machine_id_filepath) ? File.read(machine_id_filepath) : nil
end

def all_nodes_up()
  return false if get_machine_id("controlplane").nil?
  return false if get_machine_id("node01").nil?
  return false if get_machine_id("node02").nil?
  true
end

def setup_dns(node)
  node.vm.provision "setup-hosts", type: "shell", path: "ubuntu/vagrant/setup-hosts.sh" do |s|
    s.args = ["192.168.56", "NAT", NUM_WORKER_NODES, 200, 201]
  end
  node.vm.provision "setup-dns", type: "shell", path: "ubuntu/vagrant/update-dns.sh"
end

def provision_kubernetes_node(node, hostname, ip)
  node.vm.box = "ubuntu/jammy64"
  node.vm.hostname = hostname
  node.vm.network "private_network", ip: ip

  # *** THIS IS THE FIX YOU WERE MISSING ***
  node.vm.synced_folder ".", "/vagrant"

  node.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  setup_dns(node)
end

Vagrant.configure("2") do |config|

  config.vm.define "controlplane" do |controlplane|
    provision_kubernetes_node(controlplane, "controlplane", MASTER_IP)
  end

  config.vm.define "node01" do |node01|
    provision_kubernetes_node(node01, "node01", NODE01_IP)
  end

  config.vm.define "node02" do |node02|
    provision_kubernetes_node(node02, "node02", NODE02_IP)
  end

end
