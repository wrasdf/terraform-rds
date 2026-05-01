resource "aws_db_instance" "rds" {
  count                       = var.create ? 1 : 0  
  region                      = var.region

  identifier                  = var.identifier
  engine                      = local.is_replica ? null : var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = var.storage_type
  storage_encrypted           = var.storage_encrypted
  kms_key_id                  = var.kms_key_id != null ? var.kms_key_id : (aws_kms_key.key[0].arn)  
  timezone                    = var.timezone

  db_name                     = var.db_name
  username                    = !local.is_replica ? var.username : null
  password                    = !local.is_replica ? sensitive(random_string.password.result) : null
  port                        = var.port
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled

  vpc_security_group_ids      = compact(concat(var.vpc_security_group_ids, [aws_security_group.sg[0].id]))
  db_subnet_group_name        = var.db_subnet_group_name != null ? var.db_subnet_group_name : aws_db_subnet_group.subnet[0].id
  parameter_group_name        = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.parameter[0].id
  option_group_name           = var.option_group_name != null ? var.option_group_name : aws_db_option_group.option[0].id
  network_type                = var.network_type

  availability_zone           = var.availability_zone
  multi_az                    = var.multi_az
  iops                        = var.iops
  storage_throughput          = var.storage_throughput
  publicly_accessible         = var.publicly_accessible
  ca_cert_identifier          = var.ca_cert_identifier
  upgrade_storage_config      = var.upgrade_storage_config

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately == null ? (var.environment == "prod" ? false : true) : var.apply_immediately
  maintenance_window          = var.maintenance_window

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/blue-green-deployments.html
  dynamic "blue_green_update" {
    for_each = var.blue_green_update != null ? [var.blue_green_update] : []

    content {
      enabled = blue_green_update.value.enabled
    }
  } 

  snapshot_identifier                   = var.snapshot_identifier
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = local.final_snapshot_identifier
  
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = contains(["prod", "sand"], var.environment) ? var.performance_insights_retention_period : null

  replicate_source_db                   = var.replicate_source_db
  replica_mode                          = var.replica_mode
  backup_retention_period               = var.blue_green_update != null ? coalesce(var.backup_retention_period, 1) : var.backup_retention_period
  backup_window                         = var.backup_window
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? local.monitoring_role_arn : null
  database_insights_mode                = var.database_insights_mode

  character_set_name                    = var.character_set_name
  nchar_character_set_name              = var.nchar_character_set_name
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports

  deletion_protection                   = contains(["prod", "sand"], var.environment) ? var.deletion_protection : false
  delete_automated_backups              = var.delete_automated_backups

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []

    content {
      restore_time                             = restore_to_point_in_time.value.restore_time
      source_db_instance_automated_backups_arn = restore_to_point_in_time.value.source_db_instance_automated_backups_arn
      source_db_instance_identifier            = restore_to_point_in_time.value.source_db_instance_identifier
      source_dbi_resource_id                   = restore_to_point_in_time.value.source_dbi_resource_id
      use_latest_restorable_time               = restore_to_point_in_time.value.use_latest_restorable_time
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []

    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = s3_import.value.bucket_prefix
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  license_model            = var.license_model
  tags                     = merge(var.tags, var.db_instance_tags)


  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "-"
}

resource "aws_kms_key" "key" {
  count                   = var.create && var.kms_key_id == null ? 1 : 0 
  description             = "RDS ${var.identifier} key"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:Generate*",
          "kms:Verify",
          "kms:ImportKeyMaterial",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt",
          "kms:ConnectCustomKeyStore",
          "kms:Sign",
          "kms:DisableKey",
          "kms:UntagResource",
          "kms:SynchronizeMultiRegionKey",
          "kms:TagResource",
          "kms:ScheduleKeyDeletion",
          "kms:RetireGrant",
          "kms:RevokeGrant",
          "kms:DisconnectCustomKeyStore",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Enable CloudWatch Log"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  count         = var.create && var.kms_key_id == null ? 1 : 0   
  name          = "alias/${var.identifier}"
  target_key_id = aws_kms_key.key[0].key_id
}

resource "aws_db_option_group" "option" {
  count                = var.create ? 1 : 0
  name                 = "${var.identifier}-group"
  engine_name          = var.engine
  major_engine_version = local.major_engine_version
  tags                 = merge(var.tags, var.db_instance_tags)

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_db_parameter_group" "parameter" {
  count  = var.create ? 1 : 0
  name   = "${var.identifier}-group"
  family = data.aws_rds_engine_version.engine.parameter_group_family
  tags   = merge(var.tags, var.db_instance_tags)

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "subnet" {
  count      = var.create ? 1 : 0
  name       = "${var.identifier}-subnets"
  subnet_ids = data.aws_subnets.subnets.ids
  tags       = merge(var.tags, var.db_instance_tags)
}

resource "aws_cloudwatch_log_group" "log" {
  count             = var.create ? 1 : 0
  for_each          = toset(var.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/instance/${var.identifier}/${each.value}"
  retention_in_days = contains(["prod"], var.environment) ? 30 : 7
  kms_key_id        = var.kms_key_id != null ? var.kms_key_id : (aws_kms_key.key[0].arn)
  tags              = merge(var.tags, var.db_instance_tags)
}

resource "aws_ssm_parameter" "username" {
  count  = var.create ? 1 : 0
  name   = "/rds/database/${var.identifier}/username"
  type   = "SecureString"
  value  = sensitive(var.username == null ? "master" : var.username)
  key_id = var.kms_key_id != null ? var.kms_key_id : (aws_kms_key.key[0].arn)
  tags   = merge(var.tags, var.db_instance_tags)
}

resource "aws_ssm_parameter" "password" {
  count  = var.create ? 1 : 0
  name   = "/rds/database/${var.identifier}/password"
  type   = "SecureString"
  value  = sensitive(random_string.password.result)
  key_id = var.kms_key_id != null ? var.kms_key_id : (aws_kms_key.key[0].arn)
  tags   = merge(var.tags, var.db_instance_tags)
}

resource "aws_security_group" "sg" {
  count       = var.create ? 1 : 0
  name        = "${var.identifier}-rds-sg"
  description = "${var.identifier}-rds-sg"
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge(var.tags, var.db_instance_tags)
}

resource "aws_security_group_rule" "egress" {
  count             = var.create ? 1 : 0
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.sg[0].id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create ? 1 : 0
  from_port         = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.sg[0].id
  to_port           = var.port
  type              = "ingress"
  cidr_blocks       = compact(concat([data.aws_vpc.vpc.cidr_block], var.additional_ingress_cidrs))
}

resource "aws_security_group_rule" "allow_sg" {
  count    = var.create ? 1 : 0
  for_each = toset(var.allow_sg_ids)

  from_port                = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg[0].id
  to_port                  = var.port
  type                     = "ingress"
  source_security_group_id = each.value
}

resource "aws_iam_policy" "iam_auth" {
  count = var.create && length(var.db_users) > 0 ? 1 : 0

  name = "${var.identifier}-db-connect-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["rds-db:connect"]
      Effect = "Allow"
      Resource = [for user in var.db_users : format("arn:aws:rds-db:%s:%s:dbuser:%s/%s",
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        aws_db_instance.rds[0].id,
        user
      )]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "iam_auth" {
  count       = var.create && length(var.db_users) > 0 ? length(var.iam_auth_roles) : 0
  for_each    = toset(var.iam_auth_roles)

  policy_arn  = aws_iam_policy.iam_auth[0].arn
  role        = each.value
}

################################################################################
# Enhanced monitoring
################################################################################

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create && var.monitoring_interval > 0 ? 1 : 0

  name               = "${var.identifier}-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json
  description        = "The monitoring IAM role for RDS enhanced monitoring"
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.create && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
