#!/bin/bash

if ! which -s kubectl; then
  echo "kubectl command not installed"
  exit 1
fi

echo "Just run kubectl create -f ."