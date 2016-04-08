#!/bin/bash
#
# Assuming you have a kubernetes cluser and kubectl installed
# 
if kubectl get svc | grep gitlab > /dev/null 2>&1 ;
then
  echo "gitlab service already exists."              
else
  for i in *.yml
  do
    kubectl create -f $i
  done
fi

kubectl get pods
kubectl get svc
