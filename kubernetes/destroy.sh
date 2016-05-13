#!/bin/bash
#
# Assuming you have a kubernetes cluser and kubectl installed
# 
for i in *.yml
do
  kubectl delete -f $i
done
