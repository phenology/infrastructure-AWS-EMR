output "public_key" {
  value = module.dask_emr.public_key
}

output "private_key" {
  value = module.dask_emr.private_key
  sensitive = true
}

output "emr_cluster_id" {
  value = module.dask_emr.emr_cluster_id
}

output "emr_master_public_dns" {
  value = module.dask_emr.emr_master_public_dns
}

output "s3_bucket_id" {
  value = module.dask_emr.s3_bucket_id
}
