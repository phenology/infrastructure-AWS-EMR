#####
# VPC
#####

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    name = var.emr_name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true

  tags = {
    name = "public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "managed_master" {
  name        = "managed_master"
  description = "EMR managed master security group"
  vpc_id      = aws_vpc.main.id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EMR will update ingress and egress. Therefore, we ignore the changes here.
  lifecycle {
    ignore_changes = [
      ingress,
      egress,
    ]
  }
}

resource "aws_security_group" "managed_slave" {
  name        = "managed_slave"
  description = "EMR managed slave security group"
  vpc_id      = aws_vpc.main.id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EMR will update ingress and egress. Therefore, we ignore the changes here.
  lifecycle {
    ignore_changes = [
      ingress,
      egress,
    ]
  }
}

resource "aws_security_group" "public" {
  name        = "public"
  description = "Used for public instances"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  # Error: Error waiting for EMR Cluster state to be "WAITING" or "RUNNING": TERMINATED_WITH_ERRORS: VALIDATION_ERROR: The EC2 Security Groups [sg-04e0d5fb009c5a157] contain one or more ingress rules to ports other than [22] which allow public access.
  # Jupyter
  # ingress {
  #   from_port   = 8888
  #   to_port     = 8888
  #   protocol    = "tcp"
  #   cidr_blocks = var.allowed_cidr
  # }

  # Access from other security groups
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
