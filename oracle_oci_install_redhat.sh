#!/bin/bash
# Script created in 2018-12-27, 
# by Gabriel Ribas (gabriel.ribass@gmail.com)
# Script to partially automate the process of installing the kubectl and oracle oci commands

function log() {
   echo -e "$1"
}

# install packages..
if ! rpm -qa | grep -q kubectl; then 
log "install kubectl.."
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
   yum install -y kubectl
   log "Done"
fi

if ! rpm -qa | grep -q oci; then
   log "trying to install oci oracle.."
   bash -c "$(curl -sL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
fi

# starting oci setup config 
log "Enter with the informations below..\n** Connect to the unimedbhcloud tanancy in https://cloud.oracle.com **"
oci setup config


log "visit to https://console.<region>.oraclecloud.com and create API keys\ne.g. eu-frankfurt-1, uk-london-1, us-ashburn-1, us-phoenix-1\n Example.: https://console.us-ashburn-1.oraclecloud.com/a/identity/users/ocid1.user.oc1..aaaaaaaayfllmhrq3rr5sxpuhnhgj5f5h37ipumjppdnshrmbhnfdrfxlxnq\n"

log "home kubernetes command line.."
if [ ! -d $HOME/.kube ]; then
   mkdir $HOME/.kube
fi
export KUBECONFIG=$HOME/.kube/config
echo "export KUBECONFIG=\$HOME/.kube/config" >> ~/.bash_profile

log "connect to cloud.oracle.com. Menu > Developer Services > Container Cluster (OKE). Copy the cluster-id and report below ## cluster-id.:"
read k8s_cluster_id
log "recording id.."
sleep 2
exec -l $SHELL
clusterid=$k8s_cluster_id
oci ce cluster create-kubeconfig --cluster-id $clusterid --file $HOME/.kube/config

log ":) enjoy kubectl commands.. example.: kubectl get pods\n"

log "\n\n**copy content PEM public to generate oracle fingerprint.."
cat ~/$(grep "PUBLIC" .oci/* | awk -F ':' '{print $1}' | uniq)
