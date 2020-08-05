## install-k8s-centos7

```
#!/bin/bash

# CentOS K8 Prep
# Commands to prepare CentOS for installing Kubernetes
#
# OpsToDevOps
# https://opstodevops.tech
# Twitter = @opst0devops
```
############################################################
```
f_banner(){
echo
echo "
____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ 
||O |||p |||s |||T |||o |||D |||e |||v |||O |||p |||s ||
||__|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
For CentOS
Developed By OpsToDevOps @opst0devops"
echo
echo

}
```
############################################################

### Check if running with root User
```
clear
f_banner

check_root() {
if [ "$USER" != "root" ]; then
      echo "Permission Denied"
      echo "Can only be run by root"
      exit
else
      clear
      f_banner
      opstodevops_home=$(pwd)
      cat templates/texts/welcome
fi
}
```
############################################################

### Remove any old versions of Docker if they exist

```
sudo yum remove -y docker \
		docker-common \
		docker-selinux \
		docker-engine
```
############################################################

### Installing and Configuring Docker

```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce \
		docker-ce-cli \
		containerd.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $(whoami)
```
############################################################

### Step 1: Configure Kubernetes Repository
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
############################################################

### Step 2: Install kubelet, kubeadm, and kubectl
```
sudo yum install -y kubelet \
		kubeadm \
		kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet
```
############################################################

### Step 3: To give a unique hostname to master and worker nodes:
```
sudo hostnamectl set-hostname <master-node>

sudo hostnamectl set-hostname <worker-node1>
```

#### Make a host entry or DNS record to resolve the hostname for all nodes.

#### Building this lab in AWS requires Security Group to allow traffic
```
sudo vi /etc/hosts

172.31.36.85    ip-172-31-36-85.ec2.internal master-node
172.31.36.15    ip-172-31-36-15.ec2.internal worker-node1
```
############################################################

### Step 4: Configure Firewall (Optional)

#### On the Master Node enter:
```
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --reload
```

#### Enter the following commands on each worker node:
```
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
```
############################################################

### Step 5. Update Iptables (Optional)
```
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
############################################################

### Step 6: Disable SELinux
```
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```
############################################################

### Step 7: Disable SWAP
```
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a
```
############################################################

### Step 8: Create Cluster with kubeadm

#### Initialize a cluster by executing:
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### Step 9: Manage Cluster (Regular User)

#### To start using your cluster, you need to run the following as a regular user:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### Step 11: Configure Persistent Networking (Master & Worker Nodes)
```
echo "net.bridge.bridge-nf-call-iptables=1" | tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Step 12: Installing Flannel for Pod Network (Master Node Only)
```
sudo kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
```
### Step 13: Join Worker Node to Cluster
```
kubeadm join 172.31.36.85:6443 --token a78p2j.dyc856yrbt6f9qb1 \
    --discovery-token-ca-cert-hash sha256:95010b8788167f9dd087dd3ad72eaaeff6e7520878028ca79f6e8f8c0c76d9c7
```
#### OR 
```
kubeadm join --token <token> <IP>:6443
```

### Step 14: Checking Cluster Status
```
[root@master ~]# kubectl get pods --all-namespaces
NAMESPACE     NAME                             READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-c6l2v         1/1     Running   0          6h5m
kube-system   coredns-66bff467f8-tqq5t         1/1     Running   0          6h5m
kube-system   etcd-master                      1/1     Running   0          6h5m
kube-system   kube-apiserver-master            1/1     Running   0          6h5m
kube-system   kube-controller-manager-master   1/1     Running   0          6h5m
kube-system   kube-flannel-ds-amd64-49d5d      1/1     Running   0          5h54m
kube-system   kube-flannel-ds-amd64-9twww      1/1     Running   0          5h54m
kube-system   kube-flannel-ds-amd64-lfb97      1/1     Running   0          5h54m
kube-system   kube-proxy-cpwwf                 1/1     Running   0          6h5m
kube-system   kube-proxy-ngvhz                 1/1     Running   0          6h2m
kube-system   kube-proxy-xchxp                 1/1     Running   0          6h1m
kube-system   kube-scheduler-master            1/1     Running   0          6h5m

[root@master ~]# kubectl get pods -n kube-system
NAME                             READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-c6l2v         1/1     Running   0          6h5m
coredns-66bff467f8-tqq5t         1/1     Running   0          6h5m
etcd-master                      1/1     Running   0          6h5m
kube-apiserver-master            1/1     Running   0          6h5m
kube-controller-manager-master   1/1     Running   0          6h5m
kube-flannel-ds-amd64-49d5d      1/1     Running   0          5h55m
kube-flannel-ds-amd64-9twww      1/1     Running   0          5h55m
kube-flannel-ds-amd64-lfb97      1/1     Running   0          5h55m
kube-proxy-cpwwf                 1/1     Running   0          6h5m
kube-proxy-ngvhz                 1/1     Running   0          6h2m
kube-proxy-xchxp                 1/1     Running   0          6h1m
kube-scheduler-master            1/1     Running   0          6h5m

[root@master ~]# kubectl get nodes
NAME     STATUS   ROLES    AGE    VERSION
data-1   Ready    <none>   6h2m   v1.18.6
data-2   Ready    <none>   6h2m   v1.18.6
master   Ready    master   6h6m   v1.18.6
```

### Step 15: Check Cluster (Wider Output)
```
sudo kubectl get nodes -o wide

sudo kubectl get pods --all-namespaces -o wide
```
### Step 16: Start the cluster as a normal user (Optional)
```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```
