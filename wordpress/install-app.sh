#!/bin/bash
set -euo pipefail

# Login and get the Kubernetes Cluster credentials
echo "az login --service-principal -u ${azprincipal} -p ${azsecret} --tenant ${aztenant}"
az login --service-principal -u ${azprincipal} -p ${azsecret} --tenant ${aztenant}
az aks get-credentials --resource-group ${resourcegroup} --name ${clustername}

# Make sure that Helm is installed on the Kubernetes cluster

helm init 

# Wait for Helm (tiller) to be installed and running

kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system

# Install Wordpress

cat << EOF > options.yaml

wordpressUserName: ${wordpressusername}
wordpressPassword: ${wordpresspassword}
wordpressEmail: ${wordpressemail}
wordpressFirstName: ${wordpressfirstname}
wordpressLastName: ${wordpresslastname}
wordpressBlogName: ${wordpressblogname}
allowEmptyPassword: no

mariadb:
    allowEmptyPassword: no
    persistence:
        storageClass: managed-premium

persistence:
    storageClass: managed-premium

EOF

helm install -f options.yaml stable/wordpress

