## <font color='red'>Preflight - Hardware & Utils</font>  

The following playbooks configure the cluster nodes and installs k8s-1.21.6 using kubespray-2.19.1.

Prerequisites for the AlmaLinux 8.4 machines:
* A public key generated on your Ansible Controller
* Key copied to hosts
* SSH passwordless access on Nodes with root permissions

The following playbooks are run:  

#### preflight-hardware.yml
* Update packages
* Install common packages
* Turn off firewall
* Set max_map_count=262144
* Reboot Nodes

#### extra-vars.yml
* Configure the env.properties with required values

#### kubespray.yml
* Create the release directory
* Unpacks kubespray-2.19.1

#### cluster.yml
* Installs k8s 1.23.7

---

<em>Run the playbook - preflight-hardware.yml</em>  
This will update, install and configure the various required packages.

``run the playbook - preflight-hardware.yml:``
```
cd
cd /etc/ansible/playbooks
ansible-playbook -v preflight-hardware.yml
```
Note the required vars:  
- ansible_ssh_private_key_file: "~/.ssh/id_rsa"  
- ansible_ssh_private_key_file_name: "id_rsa"  
- ansible_user: k8s  
Note: Enables you to SSH into the Cluster from Ansible Controller.
---

<em>Define the playbook - extra-vars.yml</em>   
Kubespray has a bunch a default values that can be enabled to reflect your requirements.

<font color='green'>The extra-vars.yml has been created.</font>

``browse extra-vars.yml:``
```
sudo cat extra-vars.yml 
```

---

<em>Run the playbook - kubespray.yml</em>   
Kubernetes clusters can be created using various automation tools. Kubespray is a composition of Ansible playbooks, inventory, provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks. 

Kubespray provides:
* a highly available cluster
* composable attributes
* support for most popular Linux distributions

``run the download_kubespray.yml playbook:``
```
cd /etc/ansible/playbooks
ansible-playbook -v kubespray.yml
```
Note: check that the hosts-skytap.yml & extra-vars.yml have been copied.

---

<em>Run the playbook - kubespray-release-2.19.1/cluster.yml</em>   
Its is important that you explicitly include all the parameters when running the kubespray-2.19.1/cluster.yml playbook. 
Kubespray release 2.19.1 installs and configures the Foundry Platform supported version: kubernetes 1.23.7

Pre-requistes:
* Firewalls are not managed by kubespray. You'll need to implement appropriate rules as needed. You should disable your firewall in order to avoid any issues during deployment.  
* If kubespray is ran from a non-root user account, correct privilege escalation method should be configured in the target servers and the ansible_become flag or command parameters --become or -b should be specified. 

``run the cluster.yml playbook:``
```
cd
cd ~/Packages/kubespray-2.19.1
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" --become --become-user=root -v cluster.yml
```
Note: this is going to take about 6-8 mins..

** RedHat: you will need to run this command to remove Docker and Podman before deploying Kubernetes. 

<font color='green'>The following section is for Reference only.</font>

``if you need to reset the k8s deployment:``
```
cd ~/Packages/kubespray-2.19.1
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" reset.yml -b -v --become-user=root
```
Note: This will still keep some residual config files, IP routing tables, etc

``rest kubernetes cluster using kubeadm:``
```
kubeadm reset -f
```
``remove all the data from all below locations:``
```
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
```
``flush all the firewall (iptables) rules (as root):``
```
sudo -i
iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X
```
``restart the Docker service:``
```
systemctl restart docker
```

---

<em>Inventory</em>

There is a sample inventory in the inventory folder. You need to copy that and name your whole cluster (e.g. mycluster). The repository has already provided you the inventory builder to update the Ansible inventory file.  

``copy inventory/sample as inventory/mycluster:``
```
cd kubespray-release-2.19.1/inventory
sudo mkdir mycluster
cd ..
sudo chown -R installer mycluster
sudo cp -rfp sample mycluster
declare -a IPS=(10.0.0.101 10.0.0.102)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
``check inventory/mycluster/hosts.yaml``

---