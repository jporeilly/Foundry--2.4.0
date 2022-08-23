## <font color='red'>Configure Ansible</font>  

Ansible is an open source IT Configuration Management, Deployment & Orchestration tool. It aims to provide large productivity gains to a wide variety of automation challenges. This tool is very simple to use yet powerful enough to automate complex multi-tier IT application environments. 

In this lab we're going to:
* configure ansible Controller
* configure ansible Nodes

* update Inventory hosts
* add workshop directories

<font color='green'>This section is for reference only - Ansible has been installed and configured.</font>

---

#### <font color='red'>Ansible Controller Configuration</font>  

Ensure that the required pre-requisites have been completed as outlined in the previous section - 01-Infrastructure.
* create 'installer' account for ansible controller
* ensure 'installer' has root priviledges

* generate ssh keys

* update inventory file with the Node IPs 

---

<em>Create Ansible directories</em>  
``create the following directories:``
```
cd /etc/ansible
sudo mkdir playbooks
```
Note: you will have to copy over the playbooks to: ``/etc/ansible/playbooks``
or
execute the ~/Scripts/./clone_latest.sh

---

<em>Update Hosts - Inventory</em>  
You could use a basic hosts file to test the connection to the Cluster Nodes over SSH.  
Kubespray has a python module that will generate a default hosts file. 


``change directory:``
```
cd /etc/ansible
ls -al
```
``edit the hosts file:``
```
sudo nano hosts
```
``add the Node IPs (see Note below):``
```
[all]
10.0.0.101
10.0.0.102
10.0.0.103
```
``save: `` 
```
Ctrl o
Return 
Ctrl x
```
Note: You could simply add the hosts IPs, but be aware the incorrect hostnames will be written out to the /etc/hosts.  Workshop uses the complete hosts-skytap.yml so that hostnames can be resolved.

---

<em>edit the ansible.cfg</em>  
Apply the following configuration changes:    

``edit the ansible.cfg file:``
```
sudo nano ansible.cfg
```
uncomment the line (14): inventory = /etc/ansible/hosts-skytap.yml  
uncomment the line (68): roles_path = /etc/ansible/roles  
uncomment the line (71): host_key_checking = False
uncomment the line (83): callback_whitelist = profile_tasks (adds a timer to the tasks) 
uncomment the line (103): timeout=180  
uncomment the line (375): ssh_args = -C -o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=30m -o ConnectionAttempts=100  
uncomment the line (401): pipelining = False  set to True (disable requiretty in /etc/sudoers) 

Note: Ctrl + c will display line numbers.

---