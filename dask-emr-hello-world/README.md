# Quick-start example on Amazon EMR cluster with Dask

- [x] Create an Amazon EMR cluster with Dask using AWS CLI
- [x] View bootstrap logs in S3
- [x] Create a Dask cluster from the master node
- [x] Connect to the scheduler from the master node and run a test job
- [ ] Connect to the scheduler from a local machine using SSH port forwarding and run a test job
- [x] Use port forwarding for Jupyter, create a Dask cluster from a notebook and run a test job
- [ ] Run a test job on a dataset in S3

https://yarn.dask.org/en/latest/aws-emr.html

https://spell.ml/blog/large-scale-etl-jobs-using-dask-Xyl8GhEAACQAjK6h

# Create an Amazon EMR cluster with Dask

Download the example bootstrap script from https://github.com/dask/dask-yarn/blob/main/deployment_resources/aws-emr/bootstrap-dask
**This might not work. Therefore, I have modified the script in this repository. However, further fixes are still needed. See below on how to view the logs.**

```bash
aws s3 mb s3://twente-dask-emr-hello-world

# curl https://raw.githubusercontent.com/dask/dask-yarn/master/deployment_resources/aws-emr/bootstrap-dask > bootstrap.sh
aws s3 cp bootstrap.sh s3://twente-dask-emr-hello-world/bootstrap/bootstrap.sh
aws s3 ls s3://twente-dask-emr-hello-world/bootstrap/
```

Create a Hadoop cluster with EMR and specify the bootstrap scrit to install Dask.

```bash
aws emr create-cluster --name "My Dask Trial Cluster" \
  --release-label emr-5.29.0 \
  --applications Name=HADOOP \
  --log-uri s3://twente-dask-emr-hello-world/logs/ \
  --ec2-attributes KeyName=MyKeyPair \
  --instance-type m5.xlarge \
  --instance-count 3 \
  --bootstrap-actions Path=s3://twente-dask-emr-hello-world/bootstrap/bootstrap.sh,Args="[--conda-packages,bokeh,fastparquet,python-snappy,snappy]" \
  --use-default-roles \
  > cluster.json

aws emr list-clusters
# watch aws emr list-clusters --cluster-states WAITING

CLUSTER_ID=$(cat cluster.json | jq -r .ClusterId)
aws emr describe-cluster --cluster-id $CLUSTER_ID
```

SSH access

```bash
MY_IP=$(curl https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress --group-name ElasticMapReduce-master --protocol tcp --port 22 --cidr $MY_IP/32
# aws ec2 describe-security-groups --group-names ElasticMapReduce-master

MASTER_DNS_NAME=$(aws emr describe-cluster --cluster-id $CLUSTER_ID | jq -r .Cluster.MasterPublicDnsName)
ssh hadoop@$MASTER_DNS_NAME -i ../spark-emr-hello-world/mykeypair.pem

aws emr ssh --cluster-id $CLUSTER_ID --key-pair-file ../spark-emr-hello-world/mykeypair.pem

# List all nodes
yarn node -list
```

https://gist.github.com/davegravy/61e3abb81176f4490032554b70d28c31

https://github.com/dask/dask-yarn/issues/122

# View logs

```bash
MASTER_ID=$(aws emr list-instances --cluster-id $CLUSTER_ID --instance-group-types MASTER | jq -r '.Instances | first | .Ec2InstanceId')

aws s3 ls s3://twente-dask-emr-hello-world/logs/$CLUSTER_ID/node/$MASTER_ID/
aws s3 cp --quiet s3://twente-dask-emr-hello-world/logs/$CLUSTER_ID/node/$MASTER_ID/bootstrap-actions/1/stdout.gz /dev/stdout | gunzip
aws s3 cp --quiet s3://twente-dask-emr-hello-world/logs/$CLUSTER_ID/node/$MASTER_ID/bootstrap-actions/1/stderr.gz /dev/stdout | gunzip
```

# Create a Dask cluster from the master node

```bash
scp -i ../spark-emr-hello-world/mykeypair.pem create-dask-cluster.py hadoop@$MASTER_DNS_NAME:~/.
ssh -i ../spark-emr-hello-world/mykeypair.pem hadoop@$MASTER_DNS_NAME python create-dask-cluster.py
```

Scheduler will become available upon a successful start.

```bash
distributed.scheduler - INFO - Clear task state
distributed.scheduler - INFO -   Scheduler at:  tcp://172.31.2.248:46459
distributed.scheduler - INFO -   dashboard at:                    :37739
```

# Run a test job from the master node

Modify the port in the `dask-test.py` script accodingly and run it on the master node from another terminal.

```bash
scp -i ../spark-emr-hello-world/mykeypair.pem dask-test.py hadoop@$MASTER_DNS_NAME:~/.
ssh -i ../spark-emr-hello-world/mykeypair.pem hadoop@$MASTER_DNS_NAME python dask-test.py
```

Alternatively, create a cluster and run a test job in one go.

```bash
scp -i ../spark-emr-hello-world/mykeypair.pem dask-test2.py hadoop@$MASTER_DNS_NAME:~/.
ssh -i ../spark-emr-hello-world/mykeypair.pem hadoop@$MASTER_DNS_NAME python dask-test2.py
```

# Port forwarding for the scheduler

Establish port forwarding for the scheduler.

```bash
ssh -i ../spark-emr-hello-world/mykeypair.pem \
  -N -L 8786:$MASTER_DNS_NAME:38075 \
  hadoop@$MASTER_DNS_NAME
```

```bash
python -m pip install "dask[distributed]" --upgrade

python dask-test.py
```

**/Users/davids/projects/twente-emr/venv/lib/python3.8/site-packages/distributed/client.py:1134: VersionMismatchWarning: Mismatched versions found

Make sure there is the same python environment on the local as on the cluster.**

# Create a Dask cluster in Jupyter

SSH forwarding for Jupyter notebooks

```bash
scp -i ../spark-emr-hello-world/mykeypair.pem dask-test.ipynb hadoop@$MASTER_DNS_NAME:~/.

ssh -i ../spark-emr-hello-world/mykeypair.pem -N -L 8888:$MASTER_DNS_NAME:8888 hadoop@$MASTER_DNS_NAME
```

Access Jupyter in the browser http://localhost:8888/ with password `dask-user` and run the (dask-test.ipynb)[dask-test.ipynb] notebook.

# Clean-up

```bash
aws emr terminate-clusters --cluster-ids $CLUSTER_ID
```
