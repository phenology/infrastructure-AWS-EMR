module "dask_emr" {
    source = "./dask-emr"
    emr_name = var.emr_name
    master_instance_type = var.master_instance_type
    core_instance_type = var.core_instance_type
    core_instance_count = var.core_instance_count
    allowed_cidr = var.allowed_cidr
    jupyter_password = var.jupyter_password
}
