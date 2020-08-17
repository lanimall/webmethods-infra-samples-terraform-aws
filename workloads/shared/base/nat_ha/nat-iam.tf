
resource "aws_iam_instance_profile" "natinstance" {
  name_prefix  = "${module.global_common_base.name_prefix_short}-nat"
  role         = aws_iam_role.natinstance.name
}

resource "aws_iam_role" "natinstance" {
  name_prefix  = "${module.global_common_base.name_prefix_short}-nat"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.natinstance.name
}

resource "aws_iam_role_policy" "eni" {
  role        = aws_iam_role.natinstance.name
  name_prefix  = "${module.global_common_base.name_prefix_short}-nat"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}