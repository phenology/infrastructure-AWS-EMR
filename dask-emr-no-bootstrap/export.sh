#!/bin/zsh
export CLUSTER_ID=$(cat cluster.json | jq -r .ClusterId)
echo "Cluster id:" $CLUSTER_ID
export MASTER_DNS_NAME=$(aws emr describe-cluster --cluster-id $CLUSTER_ID | jq -r .Cluster.MasterPublicDnsName)
echo "Master public DNS name:" $MASTER_DNS_NAME
