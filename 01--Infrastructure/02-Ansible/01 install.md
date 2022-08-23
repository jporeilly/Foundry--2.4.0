## <font color='red'>Installation of Ansible 2.13.2</font>  

Ansible is an open source IT Configuration Management, Deployment & Orchestration tool. It aims to provide large productivity gains to a wide variety of automation challenges. This tool is very simple to use yet powerful enough to automate complex multi-tier IT application environments. 

In this lab we're going to:
* Install ansible controller

#### If you're new to Ansible you may want to take the course: [LDS3013S](https://learning.lumada.hitachivantara.com/course/introduction-to-ansible-lds3013s) - Introduction to Ansible.

<font color='green'>Ansible has been installed and configured - Reference only.</font>

---

#### <font color='red'>Pre-requisties</font>  
 
Please ensure that the Environment has been configured as outlined in the previous section - 01-Environment:
* installer user added - with sudo & passwordless privileges
* openssh server - check ssh

``apply updates:``
```
sudo apt update
sudo apt upgrade -y
sudo reboot
```

---
 
<em>Install Ansible</em> 
This installs Ansible on Ubuntu 22.04 using the PPA Repository.

``install ansible:``
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt remove ansible
sudo apt install ansible-core
```
Note: This will install Ansible 2.13.2 
Kubespray 2.17.1 requires Ansible 2.11.+ otherwise errors will occur.

``verify the installation:``
```
ansible --version
```
Note: the path to ansible.cfg  path to python & python version..  

``create ansible directory:``
```
sudo mkdir /etc/ansible
sudo mkdir /etc/ansible/playbooks
```
``check the directory:``
```
cd   /etc/ansible
ls -lrt
```
``copy over ansible.cfg:``
```
cd /home/installer/Workshop-Foundry/01--Infrastructure/02-Ansible/ansible.cfg  
sudo cp ansible.cfg /etc/ansible
```

```
Note: the directory & configuration files.
* hosts-skytap.yml - inventory file
* ansible.cfg - ansible configuration file

* roles - directory for ansible roles
```

  > for further information: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#


``to remove ansible:``
```
sudo apt-get purge --auto-remove ansible 
```

---