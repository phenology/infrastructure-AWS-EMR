output "public_key" {
  value = aws_key_pair.this.public_key
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
}

output "emr_cluster_id" {
  value = aws_emr_cluster.emr_cluster.id
}

output "emr_master_public_dns" {
  value = aws_emr_cluster.emr_cluster.master_public_dns
}

output "s3_bucket_id" {
  value = aws_s3_bucket.bucket.id
}
