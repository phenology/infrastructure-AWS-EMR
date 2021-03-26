#!/bin/zsh
export CLUSTER_ID=$(cat cluster.json | jq -r .ClusterId)
export MASTER_DNS_NAME=$(aws emr describe-cluster --cluster-id $CLUSTER_ID | jq -r .Cluster.MasterPublicDnsName)
