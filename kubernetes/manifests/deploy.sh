#!/bin/bash
set -e 
set -o pipefail

if ! command -v kubectl > /dev/null; then
  echo "kubectl command not installed"
  exit 1
fi

# create the services
for svc in *-svc.yml
do
  echo -n "Creating $svc... "
  kubectl -f $svc create
done

# create the replication controllers
for rc in *-rc.yml
do
  echo -n "Creating $rc... "
  kubectl -f $rc create
done

# list pod,rc,svc
echo "Pod:"
kubectl get pod

echo "RC:"
kubectl get rc

echo "Service:"
kubectl get svc
