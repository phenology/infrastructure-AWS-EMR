module "dask_emr" {
    source = "./dask-emr"
    emr_name = "emr-test-david"
    master_instance_type = "m5.xlarge"
    core_instance_type = "m5.2xlarge"
    core_instance_count = 4
    allowed_cidr = ["0.0.0.0/0"]
    jupyter_password = "dask-user"
}
