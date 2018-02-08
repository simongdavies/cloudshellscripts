#!/bin/bash
set -euo pipefail

# Login and get the Kubernetes Cluster credentials
echo "az login --service-principal -u ${azprincipal} -p ${azsecret} --tenant ${aztenant}"
az login --service-principal -u ${azprincipal} -p ${azsecret} --tenant ${aztenant}
az aks get-credentials --resource-group ${resourcegroup} --name ${clustername}

# Get the details of the IP address and DNS name to be associated with the Ghost install 

IP=`az network public-ip show --resource-group ${aksresourcegroup} --name ${ipname}  --query ipAddress|sed -e 's/^"//' -e 's/"$//'`
echo "IP = $IP"
DNS=`az network public-ip show --resource-group ${aksresourcegroup} --name ${ipname}  --query dnsSettings.fqdn|sed -e 's/^"//' -e 's/"$//'`
echo "DNS is $DNS"

# Make sure that Helm is installed on the Kubernetes cluster

helm init 

# Wait for Helm (tiller) to be installed and running

kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system

# Install Ghost

helm install --set serviceType=LoadBalancer,ghostHost=${DNS},ghostLoadBalancerIP=${IP} stable/ghost

