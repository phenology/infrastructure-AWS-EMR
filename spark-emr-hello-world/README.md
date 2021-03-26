# Quick-start example on Amazon EMR cluster with Spark

- [x] Create an Amazon EMR cluster with Spark using AWS CLI
- [x] Run a test job using AWS CLI and read/write from/to S3 buckets
- [x] SSH access

https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-gs.html#emr-getting-started-launch-sample-cluster

# Create an Amazon EMR cluster with Spark

```bash
aws ec2 create-key-pair --key-name MyKeyPair > ec2-key-pair.json

aws emr create-default-roles > default-roles.json
```

```bash
aws emr create-cluster \
  --name "My First EMR Cluster" \
  --release-label emr-5.32.0 \
  --applications Name=Spark \
  --ec2-attributes KeyName=MyKeyPair \
  --instance-type m5.xlarge \
  --instance-count 3 \
  --use-default-roles \
  > cluster.json

CLUSTER_ID=$(cat cluster.json | jq -r .ClusterId)
aws emr describe-cluster --cluster-id $CLUSTER_ID

aws emr list-clusters --cluster-states WAITING
# watch aws emr list-clusters --cluster-states WAITING
```

# Run a test job

```
aws s3 mb s3://twente-spark-emr-hello-world
aws s3 cp health_violations.py s3://twente-spark-emr-hello-world/health_violations.py
aws s3 cp food_establishment_data.csv s3://twente-spark-emr-hello-world/food_establishment_data.csv
aws s3 ls s3://twente-spark-emr-hello-world/

aws emr add-steps \
  --cluster-id $CLUSTER_ID \
  --steps 'Type=Spark,Name="My Spark Application",ActionOnFailure=CONTINUE,Args=[s3://twente-spark-emr-hello-world/health_violations.py,--data_source,s3://twente-spark-emr-hello-world/food_establishment_data.csv,--output_uri,s3://twente-spark-emr-hello-world/MyOutputFolder]' \
  > steps.json

STEP_ID=$(cat steps.json | jq -r '.StepIds | first')
aws emr describe-step --cluster-id $CLUSTER_ID --step-id $STEP_ID

aws s3 cp --quiet s3://twente-spark-emr-hello-world/MyOutputFolder/part-00000-dd165916-c82e-4d26-9013-760ada7c914b-c000.csv /dev/stdout
```

# SSH access

```bash
# MY_IP=$(curl ifconfig.me)
MY_IP=$(curl https://checkip.amazonaws.com)

aws ec2 authorize-security-group-ingress \
    --group-name ElasticMapReduce-master \
    --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=$MY_IP/32,Description=\"SSH access from my IP address\"}]"
# aws ec2 authorize-security-group-ingress --group-name ElasticMapReduce-master --protocol tcp --port 22 --cidr $MY_IP/32

aws ec2 describe-security-groups --group-names ElasticMapReduce-master


MASTER_DNS_NAME=$(aws emr describe-cluster --cluster-id $CLUSTER_ID | jq -r .Cluster.MasterPublicDnsName)
ssh hadoop@$MASTER_DNS_NAME -i mykeypair.pem

aws emr ssh --cluster-id $CLUSTER_ID --key-pair-file mykeypair.pem
```

# Clean-up

```bash
aws emr terminate-clusters --cluster-ids $CLUSTER_ID
```
