#####
# EMR
#####

resource "aws_emr_cluster" "emr_cluster" {
  name          = var.emr_name
  release_label = "emr-5.29.0"
  applications  = ["Hadoop"]

  ec2_attributes {
    key_name                          = aws_key_pair.this.key_name
    subnet_id                         = aws_subnet.public.id

    # The security group attributes are optional.
    # If not specified, default Amazon EMR-Managed Security Groups will be used.
    # http://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html
    additional_master_security_groups = aws_security_group.public.id
    emr_managed_master_security_group = aws_security_group.managed_master.id
    emr_managed_slave_security_group  = aws_security_group.managed_slave.id

    instance_profile                  = aws_iam_instance_profile.emr_profile.arn
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_count = var.core_instance_count
    instance_type  = var.core_instance_type
  }

  tags = {
    name = var.emr_name
  }

  bootstrap_action {
    path = "s3://${aws_s3_bucket.bucket.id}/bootstrap.sh"
    name = "emr_bootstrap"
    args = ["--password", var.jupyter_password]
  }

  service_role = aws_iam_role.iam_emr_service_role.arn

  log_uri = "s3://${aws_s3_bucket.bucket.id}/logs/"
}

resource "random_pet" "bucket" {
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.emr_name}-${random_pet.bucket.id}"
  acl    = "private"

  force_destroy = true
}

resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.bucket.id
  key    = "bootstrap.sh"
  source = "${path.module}/files/bootstrap.sh"
}
