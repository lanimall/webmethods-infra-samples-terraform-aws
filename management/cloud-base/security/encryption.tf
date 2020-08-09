############# encryption keys ############

output "aws_kms_alias_databases_arn" {
  value = aws_kms_alias.databases.arn
}

output "aws_kms_alias_buckets_arn" {
  value = aws_kms_alias.buckets.arn
}

output "aws_kms_alias_backups_arn" {
  value = aws_kms_alias.backups.arn
}

output "aws_kms_alias_ssm_arn" {
  value = aws_kms_alias.ssm.arn
}

resource "aws_kms_alias" "databases" {
  name          = "alias/${module.global_common_base.name_prefix_long}/databases"
  target_key_id = aws_kms_key.databases.key_id
}

resource "aws_kms_alias" "buckets" {
  name          = "alias/${module.global_common_base.name_prefix_long}/buckets"
  target_key_id = aws_kms_key.buckets.key_id
}

resource "aws_kms_alias" "backups" {
  name          = "alias/${module.global_common_base.name_prefix_long}/backups"
  target_key_id = aws_kms_key.backups.key_id
}

resource "aws_kms_alias" "ssm" {
  name          = "alias/${module.global_common_base.name_prefix_long}/ssm"
  target_key_id = aws_kms_key.ssm.key_id
}

resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-ssm"
    },
  )

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${module.global_common_base.name_prefix_long}-ssm",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}"
        ]
      },
      "Action": [
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
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}",
          "${aws_iam_role.app_node_role.arn}",
          "${aws_iam_role.management_node_role.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${local.account_arn}"
      },
      "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
  EOF
}

resource "aws_kms_key" "databases" {
  description             = "KMS key for databases encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-databases"
    },
  )

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${module.global_common_base.name_prefix_long}-databases",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}"
        ]
      },
      "Action": [
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
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      
      "Principal": {
        "AWS": [
          "${local.account_arn}",
           "${aws_iam_role.database.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${local.account_arn}"
      },
      "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
  EOF
}

resource "aws_kms_key" "buckets" {
  description             = "KMS key for buckets encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-buckets"
    },
  )

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${module.global_common_base.name_prefix_long}-buckets",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}"
        ]
      },
      "Action": [
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
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}",
          "${aws_iam_role.app_node_role.arn}",
          "${aws_iam_role.management_node_role.arn}",
          "${aws_iam_role.database.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${local.account_arn}"
      },
      "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
  EOF
}

resource "aws_kms_key" "backups" {
  description             = "KMS key for backups encryption"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
  
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-backups"
    },
  )

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "${module.global_common_base.name_prefix_long}-backups",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}"
        ]
      },
      "Action": [
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
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.account_arn}",
          "${aws_iam_role.app_node_role.arn}",
          "${aws_iam_role.management_node_role.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${local.account_arn}"
      },
      "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
  EOF
}

####################################################
################ IAM Policies related to using the 
################ KMS keys for decryptions
####################################################

resource "aws_iam_policy" "buckets_decrypt" {
  name_prefix = "${module.global_common_base.name_prefix_long}-buckets_decrypt"
  path        = "/"
  description = "ability to decrypt the encrypted bucket"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "${module.global_common_base.name_prefix_long}-buckets_decrypt",
    "Statement":
    [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "${aws_kms_key.buckets.arn}"
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "database_decrypt" {
  name_prefix = "${module.global_common_base.name_prefix_long}-database_decrypt"
  path        = "/"
  description = "ability to decrypt databases"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "${module.global_common_base.name_prefix_long}-database_decrypt",
    "Statement":
    [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "${aws_kms_key.databases.arn}"
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "ssm_decrypt" {
  name_prefix = "${module.global_common_base.name_prefix_long}-ssm_decrypt"
  path        = "/"
  description = "ability to decrypt params in ssm"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "${module.global_common_base.name_prefix_long}-ssm_decrypt",
    "Statement":
    [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "${aws_kms_key.ssm.arn}"
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "backup_decrypt" {
  name_prefix = "${module.global_common_base.name_prefix_long}-backup_decrypt"
  path        = "/"
  description = "ability to decrypt backups"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "${module.global_common_base.name_prefix_long}-backup_decrypt",
    "Statement":
    [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "${aws_kms_key.backups.arn}"
        }
    ]
}
  EOF
}