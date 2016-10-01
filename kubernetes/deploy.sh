#!/bin/bash

if ! which -s kubectl; then
  echo "kubectl command not installed"
  exit 1
fi

# create the services
for svc in *-svc.yml
do
  echo -n "Creating $svc... "
  kubectl -f $svc create
done

# create the deployments
for deploy in *-deploy.yml
do
  echo -n "Applying $deploy... "
  kubectl create -f $deploy --record
done

# list pod,rc,svc
echo "Pod:"
kubectl get pod

echo "RC:"
kubectl get rc

echo "Service:"
kubectl get svc
