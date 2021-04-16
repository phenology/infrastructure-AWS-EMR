# Terraform module for Amazon EMR with Dask

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster

# Module Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-------:|
| emr_name | EMR cluster name | string | emr-test-david |
| master_instance_type | Master instance type | string | m5.xlarge |
| core_instance_type | Core instance type | string | m5.xlarge |
| core_instance_count | Core instance count | number | 2 |
| allowed_cidr | CIDR blocks allowed to access the master instance on port 22 (ssh) | list | 0.0.0.0/0
| jupyter_password | Jupyter notebook server password | string | dask-user |

# Module Outputs

| Name | Description |
|------|-------------|
| public_key | Public key used for the access to the EC2 instances |
| private_ley | Private key used for the access to the EC2 instances |
| emr_cluster_id | EMR cluster id |
| emr_master_public_dns | EMS master node public DNS |
| s3_bucket_id | S3 bucket for the bootstrap script and logs | 

# Example usage

The default values for the terraform module, specified in [dask-emr/variables.tf](dask-emr/variables.tf), are overriden in [main.tf](main.tf).
In this example, a master instance of type `m5.xlarge` with 4 cores and 16 GiB memory and four core instances of type `m5.2xlarge` with 8 cores and 32 GiB memory are deployed.

```bash
terraform init
terraform plan
terraform apply
```

The bootstrap script and logs can be accessed in the S3 bucket.
This bucket will be deleted with `terraform destroy`.
Do not use it for the input and output data of your jobs.

```bash
BUCKET_ID=$(terraform output -raw s3_bucket_id)
aws s3 ls $BUCKET_ID
```

Establish SSH forwarding for the juypter notebook server.

```bash
terraform output -raw private_key > private.pem
chmod 600 private.pem
export MASTER_DNS_NAME=$(terraform output -raw emr_master_public_dns)
echo $MASTER_DNS_NAME

# ssh -i private.pem hadoop@$MASTER_DNS_NAME
ssh -i private.pem -N -L 8888:$MASTER_DNS_NAME:8888 hadoop@$MASTER_DNS_NAME
```

Access the jupyter notebook server at http://localhost:8888/

Alternatively, the port for the jupyter notebook server can be openned in the corresponding security group.
However, this is a hack. We should not be touching the infrastructure that has been deployed and is managed by Terraform.
It is on the todo list to figure out how to do this with Terraform directly.
Terraform complains when ports other than 22 are open for an EMR cluster.

```
GROUP_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=public --query "SecurityGroups[*].GroupId" | jq -r ".[0]")
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 8888 --cidr 0.0.0.0/0
```

Once deployed, the EMR cluster can be easily modified.

```bash
# Change the number of worker nodes or the flavour in main.tf
vim main.tf
terraform apply
```

Remove the infrastructure at the end.

```bash
terraform destroy
```
