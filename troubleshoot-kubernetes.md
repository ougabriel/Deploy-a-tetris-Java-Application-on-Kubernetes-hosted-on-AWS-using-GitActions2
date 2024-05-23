```bash
apt update
apt -y install vim git curl wget
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
apt-get update
swapoff -a
```


curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update 
apt-get install docker-ce docker-ce-cli containerd.io

1st Add below line and try to resraer kubelet. If it is not working then try to 2nd one
(1)

```bash
cat <<EOF | sudo tee /etc/docker/daemon.json
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
   },
       "storage-driver": "overlay2"
       }
EOF
```
(2)

```bash
cat <<EOF | sudo tee /etc/docker/daemon.json
{
      "exec-opts": ["native.cgroupdriver=cgroupfs"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
   },
       "storage-driver": "overlay2"
       }

EOF
```
installing services

```bash
apt-get install -y kubelet kubeadm kubectl

kubeadm version
kubectl version
```

vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"


```bash
vi /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"
```

```bash
systemctl daemon-reload
systemctl restart kubelet
systemctl status  kubelet
```


kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all    ----->> this will only on master
kubeadm init  --ignore-preflight-errors=all    ----->> this will only on master

•	kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml


=========================================================
 mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf


-------------------
**Checking for logs**

It looks like there's no specific Kubernetes log directory under `/var/log/`. However, you can still access logs related to Kubernetes components such as the kubelet, kube-proxy, and others.

Here are some common log files related to Kubernetes components:

- **kubelet**: `/var/log/kubelet.log`
- **kube-proxy**: `/var/log/kube-proxy.log`
- **kube-controller-manager**: `/var/log/kube-controller-manager.log`
- **kube-scheduler**: `/var/log/kube-scheduler.log`
- **etcd**: `/var/log/etcd.log` (if etcd is installed on the same node)
- **container runtime logs** (e.g., Docker): `/var/log/containers/*.log`

You can access these logs using standard file manipulation commands or tools like `tail`, `less`, or `cat`. For example:

```bash
sudo cat /var/log/kubelet.log
sudo tail -f /var/log/kube-proxy.log
```

Additionally, you can check the system logs for any errors or issues related to Kubernetes components by using `journalctl`. For example:

```bash
sudo journalctl -u kubelet
sudo journalctl -u kube-proxy
```

These commands will display logs specific to the kubelet and kube-proxy services, respectively.

If you're using a managed Kubernetes service or a Kubernetes distribution with different logging configurations, consult the documentation or support channels for guidance on accessing and interpreting logs.

