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

```bash
terraform init
terraform plan
terraform apply

terraform output -raw private_key > private.pem
chmod 600 private.pem
export MASTER_DNS_NAME=$(terraform output -raw emr_master_public_dns)
echo $MASTER_DNS_NAME

# ssh -i private.pem hadoop@$MASTER_DNS_NAME
ssh -i private.pem -N -L 8888:$MASTER_DNS_NAME:8888 hadoop@$MASTER_DNS_NAME
```

http://localhost:8888/

```bash
terraform destroy
```
