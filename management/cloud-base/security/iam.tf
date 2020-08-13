
################################################
################ outputs
################################################


############# global iam policies ############

################################################
################ outputs
################################################

output "aws_iam_role_management_node_role_id" {
  value = aws_iam_role.management_node_role.id
}

output "aws_iam_role_management_node_role_arn" {
  value = aws_iam_role.management_node_role.arn
}

output "aws_iam_instance_profile_management_node_role_id" {
  value = aws_iam_instance_profile.management_node_role.id
}

output "aws_iam_instance_profile_management_node_role_arn" {
  value = aws_iam_instance_profile.management_node_role.arn
}

output "aws_iam_role_app_node_role_id" {
  value = aws_iam_role.app_node_role.id
}

output "aws_iam_role_app_node_role_arn" {
  value = aws_iam_role.app_node_role.arn
}

output "aws_iam_instance_profile_app_node_role_id" {
  value = aws_iam_instance_profile.app_node_role.id
}

output "aws_iam_instance_profile_app_node_role_arn" {
  value = aws_iam_instance_profile.app_node_role.arn
}

output "aws_iam_role_database_id" {
  value = aws_iam_role.database.id
}

output "aws_iam_role_database_arn" {
  value = aws_iam_role.database.arn
}

output "aws_iam_role_backups_id" {
  value = aws_iam_role.backups.id
}

output "aws_iam_role_backups_arn" {
  value = aws_iam_role.backups.arn
}

################################################
################ IAM Instance Profiles
################################################

resource "aws_iam_instance_profile" "management_node_role" {
  name_prefix = "${module.global_common_base.name_prefix_short}-mgt"
  role = aws_iam_role.management_node_role.name
}

resource "aws_iam_instance_profile" "app_node_role" {
  name_prefix = "${module.global_common_base.name_prefix_short}-app"
  role = aws_iam_role.app_node_role.name
}

################################################
################ IAM roles
################################################

resource "aws_iam_role" "management_node_role" {
  name_prefix  = "${module.global_common_base.name_prefix_short}-mgt"

  assume_role_policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
POLICY
}

resource "aws_iam_role" "app_node_role" {
  name_prefix = "${module.global_common_base.name_prefix_short}-app"

  assume_role_policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
POLICY
}

resource "aws_iam_role" "database" {
  name_prefix = "${module.global_common_base.name_prefix_short}-db-rdsnode"

  assume_role_policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "rds.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
POLICY
}

resource "aws_iam_role" "backups" {
  name_prefix  = "${module.global_common_base.name_prefix_short}-backups"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

################################################
################ IAM Policies attachment
################################################

resource "aws_iam_role_policy_attachment" "management_node_role1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.management_node_role.id
}

resource "aws_iam_role_policy_attachment" "management_node_role2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.management_node_role.id
}

resource "aws_iam_role_policy_attachment" "app_node_role1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.app_node_role.id
}

resource "aws_iam_role_policy_attachment" "app_node_role2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.app_node_role.id
}

resource "aws_iam_role_policy_attachment" "backups1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backups.id
}

################################################
################ IAM Global Policies
################################################
