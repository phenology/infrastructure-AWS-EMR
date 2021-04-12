variable "emr_name" {
    type = string
    description = "EMR cluster name"
    default = "emr-test-david"
}

variable "master_instance_type" {
    type = string
    description = "Master instance type"
    default = "m5.xlarge"
}

variable "core_instance_type" {
    type = string
    description = "Core instance type"
    default = "m5.xlarge"
}

variable "core_instance_count" {
    type = number
    description = "Core instance count"
    default = 2
}

# variable "emr_bootstrap" {
#     type = string
#     description = "Location of the bootstrap script"
#     default = "s3://twente-dask-emr-hello-world/bootstrap/bootstrap.sh"
# }

variable "allowed_cidr" {
    type = list
    description = "Allowed CIDR blocks for ports 22"
    default = ["0.0.0.0/0"]
}

variable "jupyter_password" {
    type = string
    description = "Jupyter password"
    default = "dask-user"
}
