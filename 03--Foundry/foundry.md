## <font color='red'>Hitachi Vantara Foundry 2.4.0 Platform</font>  

Ansible playbooks install and configures Hitachi Vantara Foundry Platform.

Prerequisites:
* A public key generated on your Ansible Controller
* SSH passwordless access on Nodes with root permissions
* Completed 01 Infrastructure section
* Completed 02 Pre-flight section

The following playbooks are run:  

#### preflight-foundry.yml
* Update packages
* Increase max_map_count - Elasticsearch
* Configure kubectl for 'installer' access

#### storage-class.yml
* Install OpenEBS storage class

#### deploy-foundry.yml
* Create a Log directory
* Create a Foundry directory
* Unarchive Foundry Control Plane 2.4.0
* Create a Metrics directory
* Unarchive Metrics 1.0.0
* Install Cluster Services
* Run Hitachi CRDs
* Install Foundry Control Plane
* Upload Foundry charts & images
* Install Metrics Addon
* Upload Metrics image

---

<em>Run the playbook - preflight-foundry.yml</em>      
This will update, install and configure the various required packages for the Foundry Platform.
 

``run the playbook - preflight-foundry.yml:`` 
```
cd
cd /etc/ansible/playbooks
ansible-playbook -v preflight-foundry.yml
```

---

<em>Configure the Docker Registry</em>      
These steps will guide you through the installation and configuration of a local private Docker Registry.
 
By default, Docker client uses a secure connection over TLS to upload or download images to or from a private registry. 
You can use TLS certificates signed by CA or self-signed on Registry server.

<strong>Install Docker</strong>  
``install docker dependencies:``
```
cd
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```
In default package repositories of Ubuntu 22.04, Docker package is available, but it is recommended to install latest and stable version docker from their official repository.   
``enable docker:``
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
``install docker engine:``
```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```
``verify docker service:``
```
sudo systemctl status docker
```
Enter: Shift + q to escape  
``add 'installer' user to 'docker' group (without sudo):``
```
sudo usermod -aG docker $USER
```
``log out and back in to ensure '$USER' is added to 'docker' group:``
```
newgrp docker
```
``verify docker version:``
```
docker version
```
``test docker:``
```
docker run hello-world
```

<strong>Install Docker</strong>  
Credentials  
``create credentials for registry:``
```
sudo apt install apache2-utils -y
```
``create folder for credentials:``
```
mkdir -p  ~/Docker-Registry/auth
cd ~/Docker-Registry/auth
```
``create credentials:``
```
htpasswd -c -B -b passwd-file installer lumada
```
This will create passwd-file in current working directory, it will have username and encrypted password string.
``verify credentials:``
```
cat passwd-file
```

Self-signed Certificate  
``create certs directory:``
```
cd
mkdir ~/Docker-Registry/certs
cd ~/Docker-Registry/certs
```
``create certificate and key:``
```
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 365 -out ca.crt -subj "/CN=dockerhost" -addext "subjectAltName=DNS:ansible-controller.skytap.example"
```
``verify key & cert:``
```
ls
```
For any external clients aiming to communicate using SSL/TLS, copy the certificate authority file to each client that requires access to the environment
Ubuntu:  
``copy certificate to Ansible-Controller 'trust store':``
```
cd
cd ~/Docker-Registry/certs
sudo cp ca.crt /usr/local/share/ca-certificates
sudo cp ca.crt /etc/ssl/certs
sudo update-ca-certificates
```

RHEL (AlmaLinux):  
To ensure that the TLS certificates get copied over to the client certificate store on each cluster node.  
``copy ca.crt to cluster nodes:``
```
cd
cd Docker-Registry/certs
sudo scp ca.crt k8s@master-node-01.skytap.example:/etc/pki/ca-trust/source/anchors
sudo scp ca.crt k8s@master-node-02.skytap.example:/etc/pki/ca-trust/source/anchors
```
``update the certificate on each cluster node:``
```
ssh -t k8s@master-node-01.skytap.example sudo command update-ca-trust
ssh -t k8s@master-node-02.skytap.example sudo command update-ca-trust
```
Storage  
keep the default storage, located:
cd /var/lib/docker

docker.sock  
The Docker daemon runs as root. The default Unix socket therefore must be owned by root. If any other user or process owns this socket, it might be possible for that non-privileged user or process to interact with the Docker daemon.  
Visual Studio Code requires docker.sock to run as non-root.   
``change ownership of docker.sock:``
```
sudo chown installer:docker /var/run/docker.sock
```

<strong>Start Docker Registry</strong>
``start registry container:``
```
cd
cd ~/Docker-Registry/
docker run -d \
  --restart=always \
  --name private-registry \
  -v `pwd`/auth:/auth \
  -v `pwd`/certs:/certs \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/passwd-file \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/ca.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/ca.key \
  -p 443:443 \
  registry:2
```  
In the above configuration, the environment section sets up any environment variables to be included during the runtime of the container. 
The images are stored in the default location:
/var/lib/docker
Take a look at the files inside the private-registry container, using Visual Studio Code Docker extension, to view the mapped volumes - auth & certs.
``view docker registry container:``
```
docker ps
```

<strong>Test Registry</strong>  
``login to Registry:``
```
docker login -u installer https://ansible-controller.skytap.example:443
```
password: lumada

---

<em>Run the playbook - storage-class.yml</em>      
sets the storageclass.

``run the playbook - storage-class.yml:`` 
```
cd
cd /etc/ansible/playbooks
ansible-playbook -v storage-class.yml
```

---

<em>Run the playbook - deploy-foundry.yml</em> 

``run the playbook - deploy-foundry.yml:`` 
```
cd /etc/ansible/playbooks
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" -b -v deploy-foundry.yml
```
Note: It will take about 10mins to unachive the Foundry Platform package.  

you should have some logs appearing.  
``tail install-cluster-services.log: (new terminal)``
```
cd /installers/logs
ls
tail -f install-cluster-services.log
```
``check namespaces:``
```
kubectl get ns
```
Note: wait until all the cluster services have been installed, otherwise not all the namespaces will appear.  
``check the pods:``
```
kubectl get pods -A
```
``to access the Foundry Solutions Control Plane:``
```
username: foundry
echo $(kubectl get keycloakusers -n hitachi-solutions keycloak-user -o jsonpath="{.spec.user.credentials[0].value}")
```
or if you have configured .kubectl_aliases, just type ``foundry`` at command prompt.

---
