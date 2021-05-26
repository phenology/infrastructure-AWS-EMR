# Amazon EMR cluster with Dask and pre-installed packages

- [ ] Create an Amazon EMR cluster, copy pre-installed packages from S3

# Create an Amazon EMR cluster, copy pre-installed packages from S3

This exercise is about using a pre-installed conda environment rather than installing all packages during the master node bootstrap.

Install conda

```bash
# It is not possible to run packages created on a Mac on Linux EC2 instances.
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O ~/miniconda.sh
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda

source ~/miniconda/bin/activate
# conda init zsh
conda init zsh

conda update conda -y
```

Create a conda environment and install packages.

```bash
# conda env create -f environment.yml
conda create -n emr python=3.8

conda env list

conda activate emr
# conda deactivate

conda install -c conda-forge -y -q 'dask-yarn>=0.7.0' pyarrow s3fs conda-pack tornado=6.1 gdal
pip install rasterio xarray clustering-geodata-cubes

# conda env export
conda env export --from-history
# conda env export --from-history > environment.yml

conda list

conda pack -q -o environment.tar.gz --ignore-missing-files

# mkdir -p my_env
# tar -xzf environment.tar.gz -C my_env
# source my_env/bin/activate
# conda-unpack
```

https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan-bootstrap.html

```bash
# aws s3 mb s3://twente-dask-emr-hello-world
aws s3 cp environment.tar.gz s3://twente-dask-emr-hello-world/bootstrap/environment.tar.gz
aws s3 cp bootstrap-copy-env.sh s3://twente-dask-emr-hello-world/bootstrap/bootstrap-copy-env.sh
aws s3 ls s3://twente-dask-emr-hello-world/bootstrap/

aws emr create-cluster --name "My Dask Trial Cluster" \
  --release-label emr-5.29.0 \
  --applications Name=HADOOP \
  --log-uri s3://twente-dask-emr-hello-world/logs/ \
  --ec2-attributes KeyName=MyKeyPair \
  --instance-type m5.xlarge \
  --instance-count 3 \
  --bootstrap-actions Path=s3://twente-dask-emr-hello-world/bootstrap/bootstrap-copy-env.sh \
  --use-default-roles \
  > cluster.json

watch aws emr list-clusters --cluster-states WAITING

MY_IP=$(curl https://checkip.amazonaws.com)
# aws ec2 authorize-security-group-ingress --group-name ElasticMapReduce-master --protocol tcp --port 22 --cidr $MY_IP/32
# aws ec2 authorize-security-group-ingress --group-name ElasticMapReduce-master --protocol tcp --port 8888 --cidr $MY_IP/32
aws ec2 update-security-group-rule-descriptions-ingress --group-name ElasticMapReduce-master \
    --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=$MY_IP/32,Description=\"SSH access from home\"}]"
aws ec2 update-security-group-rule-descriptions-ingress --group-name ElasticMapReduce-master \
    --ip-permissions "IpProtocol=tcp,FromPort=8888,ToPort=8888,IpRanges=[{CidrIp=$MY_IP/32,Description=\"Jupyter access from home\"}]"
# aws ec2 describe-security-groups --group-names ElasticMapReduce-master

CLUSTER_ID=$(cat cluster.json | jq -r .ClusterId)
MASTER_DNS_NAME=$(aws emr describe-cluster --cluster-id $CLUSTER_ID | jq -r .Cluster.MasterPublicDnsName)

scp -i ../spark-emr-hello-world/mykeypair.pem ../dash-emr-hello-world/dask-test.ipynb hadoop@$MASTER_DNS_NAME:~/.
```

# Clean-up

```bash
aws emr terminate-clusters --cluster-ids $CLUSTER_ID
```
