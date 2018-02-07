#!/bin/bash
set -euo pipefail

# Login and get the Kubernetes Cluster credentials
az login --service-principal -u ${az-principal} -p {az-secret} --tenant ${az-tenant}
az aks get-credentials --resource-group {resource-group} --name ${cluster-name}

# Get the details of the IP address and DNS name to be associated with the Jenkins install 

IP=`az network public-ip show --resource-group {aks-resource-group} --name {ip-name}  --query ipAddress`
echo "IP = $IP"
DNS=`az network public-ip show --resource-group {aks-resource-group} --name {ip-name}  --query dnsSettings.fqdn`
echo "DNS is $DNS"

# Make sure that Helm is installed on the Kubernetes cluster

helm init --upgrade

# Wait for Helm (tiller) to be installed and running

kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system

# Install Jenkins

helm install --name jenkins --namespace jenkins stable/jenkins -f values.yaml

