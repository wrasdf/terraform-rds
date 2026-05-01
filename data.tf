data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_rds_engine_version" "engine" {
  engine       = var.engine
  version      = var.engine_version
  default_only = var.engine_default_only
}

data "aws_vpc" "vpc" {
  id = var.vpc_id

  dynamic "filter" {
    for_each = local.vpc_filter

    content {
      name   = filter.value["name"]
      values = filter.value["values"]
    }
  }
}

data "aws_subnets" "subnets" {
  dynamic "filter" {
    for_each = local.subnets_filter

    content {
      name   = filter.value["name"]
      values = filter.value["values"]
    }
  }
}


resource "random_id" "snapshot_identifier" {
  count = var.create && !var.skip_final_snapshot ? 1 : 0

  keepers = {
    id                  = var.identifier
    snapshot_identifier = var.snapshot_identifier
  }

  byte_length = 4
}

locals {

  vpc_filter = var.vpc_id == null && length(var.vpc_filter) == 0 ? [
    {
      name   = "tag:Name"
      values = ["${var.environment}-apse2-main"]
    }
  ] : []

  subnets_filter = length(var.subnets_filter) == 0 ? [
    {
      name   = "tag:Name"
      values = ["${var.environment}-apse2-main-db-*"]
    }
  ] : var.subnets_filter

  major_engine_version = var.engine == "mysql" || startswith(var.engine, "sqlserver") ? regex("\\d+.\\d+", local.engine_version) : regex("\\d+", local.engine_version)
  monitoring_role_arn  = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-${try(random_id.snapshot_identifier[0].hex, "")}"
  is_replica = var.replicate_source_db != null

}
