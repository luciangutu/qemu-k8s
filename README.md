Create infrastructure in QEMU
```shell
cd tf-code
terraform init
terraform apply
```

Configure the cluster nodes with the pre-requesites (update inventory.ini with the node IPs if needed)
```shell
ansible-playbook -i inventory.ini k8s-install.yml -v
```

Install the master node (make a note with the credentials from the output)
```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

Install the kubectl for managing the cluster (not necessary on the master)
```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```

Install the pod network manager
```shell
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Add a new node to the cluster (get the credentials from the kube init output)
```shell
sudo kubeadm join 192.168.122.2:6443 --token <...> \
	--discovery-token-ca-cert-hash sha256:<...> 
```
